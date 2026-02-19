# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin "fullcalendar", to: "https://cdn.jsdelivr.net/npm/fullcalendar@6.1.15/index.global.min.js"
pin_all_from "app/javascript/controllers", under: "controllers"
