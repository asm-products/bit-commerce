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

        @api = PayPal::SDK::AdaptivePayments.new

        # Build request object
        @pay = @api.build_pay({
          :actionType => "PAY",
          :cancelUrl => new_product_purchase_url(@product),
          :currencyCode => "USD",
          # :feesPayer => "SENDER", # Can't be used if primary receiver is specified!
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
      else
        format.html { render :new }
        format.json { render json: @purchase.errors, status: :unprocessable_entity }
      end
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

    def bit_service_fee
      ENV['BIT_SERVICE_FEE'].to_f || 0.05
    end

    def paypal_service_fee
      ENV['PAYPAL_SERVICE_FEE'].to_f || 0.0
    end

    def service_fee
      bit_service_fee + paypal_service_fee
    end

    def business_email
      # defaults to the test, development account
      ENV['BIT_BUSINESS_EMAIL'] || 'bitcommerce@bdhr.co'
    end
end
