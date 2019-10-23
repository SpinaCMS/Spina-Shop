# Upgrading Spina-Shop to newer versions

## Credit invoices
Todo's:
- Migrate existing invoices to correct paid attribute
- Change InvoiceGenerator for postpay invoices to set paid to false
- Deleted `postpay` method on `Spina::Shop::Order`. Include it in your own decorator if you need it.