# Bit Commerce

<a href="https://assembly.com/bit-commerce/bounties?utm_campaign=assemblage&utm_source=bit-commerce&utm_medium=repo_badge"><img src="https://asm-badger.herokuapp.com/bit-commerce/badges/tasks.svg" height="24px" alt="Open Tasks" /></a>

## Sell digital products from your cloud storage account

This is a product being built by the Assembly community. You can help push this idea forward by visiting [https://assembly.com/bit-commerce](https://assembly.com/bit-commerce).

### How Assembly Works

Assembly products are like open-source and made with contributions from the community. Assembly handles the boring stuff like hosting, support, financing, legal, etc. Once the product launches we collect the revenue and split the profits amongst the contributors.

Visit [https://assembly.com](https://assembly.com) to learn more.

## Installation

    bundle install --without production
    ./bin/rake db:setup

## Running

1. Start rails server

        ./bin/rails s

2. Visit localhost at port 3000:

    [http://localhost:3000/products/new](http://localhost:3000/products/new)

## Deploy to Heroku

    git remote add heroku git@heroku.com:bitcommerce.git
    git push heroku master
    heroku run bin/rake db:migrate
