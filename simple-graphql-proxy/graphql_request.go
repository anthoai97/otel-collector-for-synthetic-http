package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"simple-proxy/core"
)

func ProxyToGraphQL(hotelCode string) (int, []byte) {
	// GraphQL server endpoint
	url := core.GetEnvVar("DOMAIN", "<>")

	// GraphQL query
	query := `
    query HotelList($filter: HotelFilter) {
		response: hotelList(filter: $filter) {
		  count
		  totalPage
		  data {
			... on Hotel {
			  id
			  name
			  code
			  timeZone
			  iconImageUrl
			  iconSymbolUrl
			  state
			  address
			  phoneNumber
			  emailAddressList
			  postalCode
			  signature
			  backgroundCategoryImageUrl
			  customThemeImageUrl
			  lowestPriceImageUrl
			  measureMetric
			  isCityTaxIncludedSellingPrice
			  brand {
				name
			  }
			  country {
				code
				name
				phoneCode
				translationList {
				  languageCode
				  name
				}
			  }
			  taxSetting
			  serviceChargeSetting
			  hotelPaymentModeList {
				id
				code
				name
				description
			  }
			  hotelConfigurationList {
				configType
				configValue {
				  minChildrenAge
				  maxChildrenAge
				  maxChildrenCapacity
				  colorCode
				  shortDescription
				  content
				  title
				  value
				  metadata
				}
			  }
			  paymentAccount {
				paymentId
				publicKey
				type
				subMerchantId
			  }
			  baseCurrency {
				code
				currencyRateList {
				  rate
				  exchangeCurrency {
					code
				  }
				}
			  }
			  stayOptionBackgroundImageUrl
			  customizeStayOptionBackgroundImageUrl
			  stayOptionSuggestionImageUrl
			  signatureBackgroundImageUrl
			}
		  }
		}
	  }
	`

	// GraphQL variables
	variables := map[string]interface{}{
		"filter": map[string]interface{}{
			"hotelCode": hotelCode,
			"expand": []string{
				"country",
				"currency",
				"currencyRate",
				"hotelConfiguration",
				"hotelPaymentAccount",
				"hotelPaymentMode",
				"iconImage",
			},
		},
	}

	// Create the GraphQL request body
	requestBody := map[string]interface{}{
		"query":     query,
		"variables": variables,
	}

	// Convert request body to JSON
	jsonData, err := json.Marshal(requestBody)
	if err != nil {
		fmt.Println("Error encoding JSON:", err)
		return 404, nil
	}

	// Create the HTTP request
	req, err := http.NewRequest("POST", url, bytes.NewBuffer(jsonData))
	if err != nil {
		fmt.Println("Error creating request:", err)
		return 404, nil
	}

	// Set headers
	req.Header.Set("Content-Type", "application/json")

	// Make the HTTP request
	client := http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		fmt.Println("Error making request:", err)
		return resp.StatusCode, nil
	}
	defer resp.Body.Close()

	// Read the response body
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		fmt.Println("Error reading response body:", err)
		return resp.StatusCode, nil
	}

	// Print the response body
	return resp.StatusCode, body
}
