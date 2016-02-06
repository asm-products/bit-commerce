class PurchasesController < ApplicationController
  skip_before_filter :product_session, only: [:show, :new, :create]

  before_action :set_purchase, only: [:show, :update, :destroy]
  before_action :set_product, only: [:index, :show, :new, :create]

  # GET /purchases
  # GET /purchases.json
  def index
    @purchases = @product.purchases
  end

  # GET /purchases/1
  # GET /purchases/1.json
  def show
  end

  # GET /purchases/new
  def new
    @purchase = Purchase.new
  end

  # POST /purchases
  # POST /purchases.json
  def create
    @purchase = Purchase.new(purchase_params.merge(product: @product))

    respond_to do |format|
      if @purchase.save
        make_payment(format)
      else
        format.html { render :new }
        format.json { render json: @purchase.errors, status: :unprocessable_entity }
      end
    end
  end

  def make_payment(format)
    if adaptive_payments?
      _make_adaptive_payment format
    else
      _make_paypal_payment format
    end
  end

  def _make_adaptive_payment(format)
    @api = PayPal::SDK::AdaptivePayments.new

    # Build request object
    @pay = @api.build_pay({
      :actionType => "PAY",
      :cancelUrl => new_product_purchase_url(@product),
      :currencyCode => "USD",
      :receiverList => {
        :receiver => [
          {
            :amount => @product.price,
            :email => business_email,
            :primary => true
          },
          {
            :amount => @product.price - (@product.price * service_fee),
            :email => @product.email
          }
        ] },
        :returnUrl => product_purchase_url(@product, @purchase)
    })

    # Make API call & get response
    @response = @api.pay(@pay)

    # Access response
    if @response.success? && @response.payment_exec_status != "ERROR"
      @purchase.update_attribute :paypal_pay_key, @response.payKey
      format.html { redirect_to @api.payment_url(@response) } # Url to complete payment
    else
      # TODO: log errors, notify team and show something humman readable
      # to the user ;)
      raise @response.error[0].message.to_yaml
    end
  end

  def _make_paypal_payment(format)
    @payment = PayPal::SDK::REST::Payment.new({
      :intent =>  "sale",

      :payer =>  {
        :payment_method =>  "paypal"
      },

      :redirect_urls => {
        :return_url => product_purchase_url(@product, @purchase),
        :cancel_url => new_product_purchase_url(@product)
      },

      :transactions =>  [{
        :item_list => {
          :items => [{
            :name => @product.title,
            :price => sprintf("%.2f" % @product.price),
            :currency => "USD",
            :quantity => 1
          }]
        },

        :amount =>  {
          :total =>  sprintf("%.2f" % @product.price),
          :currency =>  "USD"
        }
      }]
    })

    if @payment.create
      @purchase.update_attribute :paypal_payment_id, @payment.id

      # Redirect the user to given approval url
      @redirect_url = @payment.links.find{|v| v.method == "REDIRECT" }.href
      format.html { redirect_to @redirect_url } # Url to complete payment
    else
      # TODO: log errors, notify team and show something humman readable
      # to the user ;)
      raise @payment.error.inspect
    end
  end

  # PATCH/PUT /purchases/1
  # PATCH/PUT /purchases/1.json
  def update
    respond_to do |format|
      if @purchase.update(purchase_params)
        format.html { redirect_to @purchase, notice: 'Purchase was successfully updated.' }
        format.json { render :show, status: :ok, location: @purchase }
      else
        format.html { render :edit }
        format.json { render json: @purchase.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /purchases/1
  # DELETE /purchases/1.json
  def destroy
    @purchase.destroy
    respond_to do |format|
      format.html { redirect_to purchases_url, notice: 'Purchase was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_purchase
      @purchase = Purchase.find_by(token: params[:id])
    end

    def set_product
      @product = Product.find_by(token: params[:product_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def purchase_params
      params.require(:purchase).permit(:email)
    end

    def service_fee
      (ENV['BIT_SERVICE_FEE'] || 0.05).to_f
    end

    def business_email
      # defaults to the test, development account
      ENV['BIT_BUSINESS_EMAIL'] || 'bitcommerce@bdhr.co'
    end

    def adaptive_payments?
      ENV['BIT_ADAPTIVE'] == 'true' || false
    end
end
