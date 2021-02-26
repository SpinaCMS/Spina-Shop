(() => {
  const application = Stimulus.Application.start()

  application.register("order-form", class extends Stimulus.Controller {

    static get targets() {
      return ["customerId", "name", "firstName", "lastName", "email", "phone", "company", "billingStreet1", "billingStreet2", "billingHouseNumber", "billingHouseNumberAddition", "billingPostalCode", "billingCity", "billingCountry"]
    }

    copy_details() {
      fetch(`/admin/shop/customers/${this.customerIdTarget.value}.json`).then(function(response) {
        return response.text()
      }).then(function(json) {
        json = JSON.parse(json)

        // Details
        if (this.hasNameTarget) this.nameTarget.value = `${json.first_name} ${json.last_name}`
        if (this.hasFirstNameTarget) this.firstNameTarget.value = json.first_name
        if (this.hasLastNameTarget) this.lastNameTarget.value = json.last_name
        if (this.hasEmailTarget) this.emailTarget.value = json.email
        if (this.hasPhoneTarget) this.phoneTarget.value = json.phone
        if (this.hasCompanyTarget) this.companyTarget.value = json.company

        // Billing address
        if (this.hasBillingStreet1Target) this.billingStreet1Target.value = json.billing_street_1
        if (this.hasBillingStreet2Target) this.billingStreet2Target.value = json.billing_street_2
        if (this.hasBillingHouseNumberTarget) this.billingHouseNumberTarget.value = json.billing_house_number
        if (this.hasBillingHouseNumberAdditionTarget) this.billingHouseNumberAdditionTarget.value = json.billing_house_number_addition
        if (this.hasBillingPostalCodeTarget) this.billingPostalCodeTarget.value = json.billing_postal_code
        if (this.hasBillingCityTarget) this.billingCityTarget.value = json.billing_city
        if (this.hasBillingCountryTarget) this.billingCountryTarget.value = json.billing_country
      }.bind(this))
    }

  })
})()