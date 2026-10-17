import os;

obj Event {
    has id: str;
    has title: str;
    has category: str;
    has university: str;
    has date_label: str;
    has event_date: str;
    has time: str;
    has venue: str;
    has description: str;
    has sport: str = "";
    has additional_info: str = "";
    has deadline: str = "";
    has buy_url: str = "";
    has price: int = 0;
    has seats: int = 0;
    has live: bool = False;
    has zoom_url: str = "";
    has thumbnail: str = "";
    has visibility: str = "Public";
    has accent: str = "blue";
}

glob _EVENTS: list[Event] = [
    Event(id="e1", title="Future of AI: Ideas in Motion", category="Educational", university="University of Colombo", date_label="OCT 22", event_date="2026-10-22", time="9:30 AM", venue="New Arts Theatre", description="A full day of talks and hands-on sessions exploring how artificial intelligence is shaping research, work and everyday life.", price=0, seats=0, live=True, zoom_url="https://zoom.us/j/123456789", accent="blue"),
    Event(id="e2", title="Inter-uni Basketball Finals", category="Sports", university="University of Colombo", date_label="OCT 25", event_date="2026-10-25", time="4:00 PM", venue="University Sports Complex", description="The season reaches its peak. Come back your campus and catch the final buzzer live.", sport="Basketball", price=800, seats=18, accent="coral"),
    Event(id="e3", title="Midnight at the Museum", category="Entertainment", university="University of Colombo", date_label="OCT 29", event_date="2026-10-29", time="7:00 PM", venue="National Museum Courtyard", description="An open-air night of live music, student DJs and food beneath the stars. Bring your friends.", price=1500, seats=96, accent="purple"),
    Event(id="e4", title="Design Futures Forum", category="Educational", university="University of Colombo", date_label="NOV 02", event_date="2026-11-02", time="10:00 AM", venue="Faculty of Graduate Studies", description="A student-led forum on thoughtful design, creative technology and building a more human future.", price=0, live=True, zoom_url="https://zoom.us/j/987654321", accent="green"),
    Event(id="e5", title="Campus Classics Hoodie", category="Merch", university="University of Colombo", date_label="NOV 06", event_date="2026-11-06", time="All day", venue="Student Union Shop", description="A limited-run, heavyweight hoodie made by students for students. Pick up on campus.", price=6500, seats=30, deadline="2026-11-04", accent="blue"),
    Event(id="e6", title="Inter-uni Rugby Shield", category="Sports", university="University of Colombo", date_label="NOV 10", event_date="2026-11-10", time="3:30 PM", venue="Racecourse Grounds", description="Rival campuses meet for the annual rugby shield. Gates open one hour before kick-off.", sport="Rugby", price=1000, seats=65, accent="coral")
];

def:pub list_events() -> list[Event] {
    return [event for event in _EVENTS if event.visibility == "Public"];
}

def:pub list_all_events() -> list[Event] {
    return _EVENTS;
}

def:pub list_universities() -> list[str] {
    return sorted(list(set([event.university for event in _EVENTS])));
}

def:pub reserve_ticket(event_id: str) -> str {
    for event in _EVENTS {
        if event.id == event_id {
            if event.category == "Educational" { return "Educational events are free to attend; no ticket is required."; }
            if event.category == "Merch" { return "Use the Buy link on this item to place your order."; }
            if event.seats > 0 {
                event.seats = event.seats - 1;
                return "You're on the list for " + event.title + ". Ticket payment can be completed when checkout is connected.";
            }
            return "This event is sold out.";
        }
    }
    return "Event not found.";
}

def _is_admin(username: str, password: str) -> bool {
    expected_user = os.getenv("UNIVERSE_ADMIN_USERNAME", "");
    expected_password = os.getenv("UNIVERSE_ADMIN_PASSWORD", "");
    return len(expected_user) > 0 and len(expected_password) > 0 and username == expected_user and password == expected_password;
}

def:pub admin_login(username: str, password: str) -> bool {
    return _is_admin(username, password);
}

def:pub admin_list_events(username: str, password: str) -> list[Event] {
    if _is_admin(username, password) { return _EVENTS; }
    return [];
}

def _event_from(payload: dict) -> Event | None {
    try {
        price_value = int(payload["price"]);
        seat_value = int(payload["seats"]);
        title_value = str(payload["title"]).strip();
        university_value = str(payload["university"]).strip();
        if len(title_value) == 0 or len(university_value) == 0 or price_value < 0 or seat_value < 0 { return None; }
        return Event(id=str(payload["id"]), title=title_value, category=str(payload["category"]), university=university_value, event_date=str(payload["event_date"]), date_label=str(payload["date_label"]), time=str(payload["time"]), venue=str(payload["venue"]), description=str(payload["description"]), sport=str(payload["sport"]), price=price_value, seats=seat_value, live=bool(payload["live"]), zoom_url=str(payload["zoom_url"]), thumbnail=str(payload["thumbnail"]), additional_info=str(payload["additional_info"]), deadline=str(payload["deadline"]), buy_url=str(payload["buy_url"]), visibility=str(payload["visibility"]));
    } except Exception {
        return None;
    }
}

def:pub create_event(username: str, password: str, item: dict) -> Event | None {
    if not _is_admin(username, password) { return None; }
    new_event = _event_from(item);
    if new_event is None { return None; }
    for existing in _EVENTS { if existing.id == new_event.id { return None; } }
    _EVENTS = _EVENTS + [new_event];
    return new_event;
}

def:pub update_event(username: str, password: str, item: dict) -> Event | None {
    if not _is_admin(username, password) { return None; }
    updated = _event_from(item);
    if updated is None { return None; }
    for (index, old_event) in enumerate(_EVENTS) {
        if old_event.id == updated.id {
            updated.accent = old_event.accent;
            _EVENTS[index] = updated;
            return updated;
        }
    }
    return None;
}

def:pub remove_event(username: str, password: str, id: str) -> bool {
    if not _is_admin(username, password) { return False; }
    original_count = len(_EVENTS);
    _EVENTS = [event for event in _EVENTS if event.id != id];
    return len(_EVENTS) < original_count;
}

def:pub upload_event_thumbnail(username: str, password: str, data_url: str) -> str {
    if not _is_admin(username, password) or not data_url.startswith("data:image/") or len(data_url) > 700000 { return ""; }
    return data_url;
}

def:pub get_my_university_events(application_id: str) -> list[Event] {
    application = [app for app in [root.shared -->][?:StudentVerification] if jid(app) == application_id and app.status == "Approved" and app.payment_status == "Paid"];
    if len(application) == 0 { return []; }
    university = application[0].university;
    return [event for event in _EVENTS if event.university == university];
}
