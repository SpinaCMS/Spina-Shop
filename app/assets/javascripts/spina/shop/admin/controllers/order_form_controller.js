(() => {
  const application = Stimulus.Application.start()

  application.register("order-form", class extends Stimulus.Controller {

    static get targets() {
      return ["customerId", "firstName", "lastName", "email", "phone", "company", "billingStreet1", "billingStreet2", "billingHouseNumber", "billingHouseNumberAddition", "billingPostalCode", "billingCity", "billingCountry"]
    }

    copy_details() {
      fetch(`/admin/shop/customers/${this.customerIdTarget.value}.json`).then(function(response) {
        return response.text()
      }).then(function(json) {
        json = JSON.parse(json)

        // Details
        this.firstNameTarget.value = json.first_name
        this.lastNameTarget.value = json.last_name
        this.emailTarget.value = json.email
        this.phoneTarget.value = json.phone
        this.companyTarget.value = json.company

        // Billing address
        this.billingStreet1Target.value = json.billing_street_1
        this.billingStreet2Target.value = json.billing_street_2
        this.billingHouseNumberTarget.value = json.billing_house_number
        this.billingHouseNumberAdditionTarget.value = json.billing_house_number_addition
        this.billingPostalCodeTarget.value = json.billing_postal_code
        this.billingCityTarget.value = json.billing_city
        this.billingCountryTarget.value = json.billing_country
      }.bind(this))
    }

  })
})()