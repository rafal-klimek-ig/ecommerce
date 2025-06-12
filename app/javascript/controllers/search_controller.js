// app/javascript/controllers/search_controller.js

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static debounceTimeout = 500

  connect() {
    this.timeout = null
  }

  disconnect() {
    if (this.timeout) {
      clearTimeout(this.timeout)
    }
  }

  search(event) {
    // Clear existing timeout
    clearTimeout(this.timeout)

    // Set new timeout for debounced search
    this.timeout = setTimeout(() => {
      this.element.requestSubmit()
    }, this.constructor.debounceTimeout)
  }

  submit(event) {
    // Immediate submit for dropdowns and buttons
    this.element.requestSubmit()
  }

  clear(event) {
    // Clear the form and submit
    event.preventDefault()
    this.element.reset()
    this.element.requestSubmit()
  }
}
