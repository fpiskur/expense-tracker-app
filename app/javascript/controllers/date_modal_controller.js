import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="date-modal"
export default class extends Controller {
  connect() {
    let parentElement = document.querySelector(".month-controls");
    let fixedChild = document.querySelector(".month-controls__manual");

    let parentWidth = getComputedStyle(parentElement).width;
    fixedChild.style.width = parentWidth;
  }

  toggle() {
    let modal = document.querySelector('.month-controls__manual');

    modal.classList.toggle('hidden');
  }
}
