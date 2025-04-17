// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import "./controllers"
import "./channels"
import $ from 'jquery';
window.jQuery = window.$ = $;
import "./goals";