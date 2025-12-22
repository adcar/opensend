import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.element.addEventListener('dragenter', this.handleDragEnter.bind(this))
    this.element.addEventListener('dragover', this.handleDragOver.bind(this))
    this.element.addEventListener('dragleave', this.handleDragLeave.bind(this))
    this.element.addEventListener('drop', this.handleDrop.bind(this))
  }
  
  handleDragEnter(e) {
    e.preventDefault()
    e.stopPropagation()
    this.element.classList.add('dropzone-active')
  }
  
  handleDragOver(e) {
    e.preventDefault()
    e.stopPropagation()
  }
  
  handleDragLeave(e) {
    e.preventDefault()
    e.stopPropagation()
    this.element.classList.remove('dropzone-active')
  }
  
  handleDrop(e) {
    e.preventDefault()
    e.stopPropagation()
    this.element.classList.remove('dropzone-active')
  }
}

