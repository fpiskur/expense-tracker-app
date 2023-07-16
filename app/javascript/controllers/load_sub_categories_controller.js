import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="load-sub-categories"
export default class extends Controller {
  load(event) {
    let parentId = event.target.value;
    let subCatGroups = document.querySelectorAll('.sub-cat-group');
    let targetElement = document.getElementById(`sub-cat-${parentId}`);

    if (subCatGroups) {
      subCatGroups.forEach(group => {
        group.classList.add('hidden');
      });
    }

    targetElement.classList.remove('hidden');
  }
}
