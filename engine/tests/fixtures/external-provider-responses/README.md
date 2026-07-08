# External Provider Responses

Place completed external provider response JSON files in this directory.

Generate a blank template with:

```bash
npm run provider:response-template -- ../../outputs/external-provider-response-template.json
npm run provider:response-csv -- ../../outputs/external-provider-response.csv
npm run provider:csv-to-json -- ../../outputs/external-provider-response.csv tests/fixtures/external-provider-responses/<provider-name>-YYYY-MM-DD.json
```

Run `npm run test:manseryeok` after adding or changing a response file.
