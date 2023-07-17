import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="load-sub-categories"
export default class extends Controller {
  load(event) {
    let parentId = event.target.value;
    let subCatGroups = document.querySelectorAll('.sub-cat-group');
    let targetElement = document.getElementById(`sub-cat-${parentId}`);
    let parentCategoryBtn = document.getElementById(`expense_category_id_${parentId}`);

    if (subCatGroups) {
      subCatGroups.forEach(group => {
        group.classList.add('hidden');
      });
    }

    if (targetElement) {
      parentCategoryBtn.checked = false;
      targetElement.classList.remove('hidden');
    }
  }
}
