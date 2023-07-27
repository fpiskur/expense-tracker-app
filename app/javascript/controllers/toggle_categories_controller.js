import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="toggle-categories"
export default class extends Controller {
  static targets = ['id', 'hasChildren'];

  toggle(event) {
    let clickedCategory = event.target;
    let clickedCategoryId = this.data.get('id');
    let clickedCategoryHasChildren = this.data.get('hasChildren');
    let targetSubCategoriesList = document.getElementById(`sub-cat-group-${clickedCategoryId}`);

    if (clickedCategoryHasChildren === 'true') {
      if (clickedCategory.classList.contains('opened')) {
        clickedCategory.classList.remove('opened');
        clickedCategory.classList.add('closed');
        targetSubCategoriesList.classList.add('hidden');
      } else {
        clickedCategory.classList.remove('closed');
        clickedCategory.classList.add('opened');
        targetSubCategoriesList.classList.remove('hidden');
      }
    }
  }
}
