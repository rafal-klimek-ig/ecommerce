import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  formatCard(event) {
    let value = event.target.value.replace(/\s+/g, '').replace(/[^0-9]/gi, '')
    let formattedValue = value.match(/.{1,4}/g)?.join(' ') || value
    event.target.value = formattedValue
  }

  formatExpiry(event) {
    let value = event.target.value.replace(/\D/g, '')
    if (value.length >= 2) {
      value = value.substring(0, 2) + '/' + value.substring(2, 4)
    }
    event.target.value = value
  }

  formatCVV(event) {
    let value = event.target.value.replace(/\D/g, '')
    event.target.value = value
  }
}
