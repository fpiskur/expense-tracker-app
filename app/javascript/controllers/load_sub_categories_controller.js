import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="load-sub-categories"
export default class extends Controller {
  load(event) {
    let parentId = event.target.value;
    let subCatGroups = document.querySelectorAll('.sub-cat-group');
    let categoryLabels = document.querySelectorAll('.custom-radio-btn');
    let targetElement = document.getElementById(`sub-cat-${parentId}`);
    let parentCategoryBtn = document.getElementById(`expense_category_id_${parentId}`);
    let parentCategoryLabel = document.querySelector(`label[for=expense_category_id_${parentId}]`);

    if (subCatGroups) {
      subCatGroups.forEach(group => {
        group.classList.add('hidden');
      });
    }

    if (categoryLabels) {
      categoryLabels.forEach(label => {
        label.classList.remove('btn--light');
        label.classList.add('btn--primary');
      })
    }

    if (targetElement) {
      parentCategoryBtn.checked = false;
      parentCategoryLabel.classList.remove('btn--primary');
      parentCategoryLabel.classList.add('btn--light');
      targetElement.classList.remove('hidden');
    }
  }
}
