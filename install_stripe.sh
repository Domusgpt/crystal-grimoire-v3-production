#!/bin/bash
# Quick Stripe Extension Install with preset config

firebase ext:install stripe/firestore-stripe-payments \
  --params='{
    "STRIPE_API_KEY": "YOUR_STRIPE_SECRET_KEY
    "CUSTOMERS_COLLECTION": "customers",
    "PRODUCTS_COLLECTION": "products", 
    "PRICES_COLLECTION": "prices",
    "DEFAULT_CURRENCY": "usd",
    "SYNC_USERS_ON_CREATE": "yes",
    "AUTOMATICALLY_DELETE_STRIPE_CUSTOMERS": "no"
  }' \
  --project=crystalgrimoire-v3-production