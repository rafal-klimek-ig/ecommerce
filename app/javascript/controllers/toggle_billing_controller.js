import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["billingSection"]

  toggle(event) {
    if (event.target.checked) {
      this.billingSectionTarget.classList.add("hidden")
    } else {
      this.billingSectionTarget.classList.remove("hidden")
    }
  }
}