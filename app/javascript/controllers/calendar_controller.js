import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static values = {
        eventsUrl: String,
        newEventUrl: String
    }

    static targets = ["container"]

    connect() {
        this.initCalendar()
    }

    disconnect() {
        if (this.calendar) {
            this.calendar.destroy()
        }
    }

    initCalendar() {
        const { Calendar } = FullCalendar

        this.calendar = new Calendar(this.containerTarget, {
            initialView: "dayGridMonth",
            headerToolbar: {
                left: "prev,next today",
                center: "title",
                right: "dayGridMonth,timeGridWeek,timeGridDay"
            },
            editable: true,
            selectable: true,
            selectMirror: true,
            dayMaxEvents: true,
            events: {
                url: this.eventsUrlValue,
                failure: () => console.error("Failed to fetch events")
            },
            select: (info) => {
                this.openModal(this.buildNewEventUrl(info))
                this.calendar.unselect()
            },
            eventClick: (info) => {
                info.jsEvent.preventDefault()
                if (info.event.url) {
                    this.openModal(info.event.url)
                }
            },
            eventDrop: (info) => this.updateEventDates(info),
            eventResize: (info) => this.updateEventDates(info)
        })

        this.calendar.render()
    }

    buildNewEventUrl(info) {
        const url = new URL(this.newEventUrlValue, window.location.origin)
        url.searchParams.set("start", info.startStr)
        url.searchParams.set("end", info.endStr)
        url.searchParams.set("all_day", info.allDay)
        return url.toString()
    }

    openModal(url) {
        document.getElementById("modal").src = url
        document.getElementById("event-modal-backdrop").classList.remove("hidden")
    }

    closeModal() {
        document.getElementById("event-modal-backdrop").classList.add("hidden")
        document.getElementById("modal").src = ""
        this.calendar.refetchEvents()
    }

    updateEventDates(info) {
        fetch(`/events/${info.event.id}`, {
            method: "PATCH",
            headers: {
                "Content-Type": "application/json",
                "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
                "Accept": "application/json"
            },
            body: JSON.stringify({
                event: {
                    start_datetime: info.event.startStr,
                    end_datetime: info.event.endStr,
                    all_day: info.event.allDay
                }
            })
        }).then(response => {
            if (!response.ok) info.revert()
        }).catch(() => info.revert())
    }
}