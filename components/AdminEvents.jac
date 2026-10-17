import from ..services.events { Event, admin_list_events, create_event, update_event, remove_event }
import from .ui.card { Card, CardContent }
import from .ui.button { Button }
import from .ui.input { Input }
import from "@jac/runtime" { Link, useNavigate }

 def:pub AdminEvents() -> JsxElement {
    has events: list[Event] = [];
    has title: str = "";
    has category: str = "Educational";
    has university: str = "University of Colombo";
    has date: str = "2026-11-20";
    has date_label: str = "NOV 20";
    has time: str = "6:00 PM";
    has venue: str = "University campus";
    has description: str = "";
    has price: str = "0";
    has detail_link: str = "";
    has thumbnail: str = "";
    has additional_info: str = "";
    has deadline: str = "";
    has buy_url: str = "";
    has visibility: str = "Public";
    has editing_id: str = "";
    has status: str = "";
    nav = useNavigate();
    async can with entry {
        username = localStorage.getItem("uv_admin_user") or "";
        password = localStorage.getItem("uv_admin_pass") or "";
        if username == "" or password == "" {
            nav("/universe-admin");
        } else { events = await admin_list_events(username, password); }
    }
    def on_title(e: ChangeEvent) { title = e.target.value; }
    def on_category(e: ChangeEvent) { category = e.target.value; }
    def on_university(e: ChangeEvent) { university = e.target.value; }
    def on_date(e: ChangeEvent) { date = e.target.value; }
    def on_date_label(e: ChangeEvent) { date_label = e.target.value; }
    def on_time(e: ChangeEvent) { time = e.target.value; }
    def on_venue(e: ChangeEvent) { venue = e.target.value; }
    def on_description(e: ChangeEvent) { description = e.target.value; }
    def on_price(e: ChangeEvent) { price = e.target.value; }
    def on_link(e: ChangeEvent) { detail_link = e.target.value; }
    def on_additional_info(e: ChangeEvent) { additional_info = e.target.value; }
    def on_deadline(e: ChangeEvent) { deadline = e.target.value; }
    def on_buy_url(e: ChangeEvent) { buy_url = e.target.value; }
    def on_visibility(e: ChangeEvent) { visibility = e.target.value; }
    def on_file(e: ChangeEvent) {
        files: any = e.target.files;
        file: any = files[0];
        if file and str(file.type).startswith("image/") and (file.size as int) <= 450000 {
            reader: any = new(FileReader as type);
            reader.onload = lambda (ev: any) { thumbnail = str(ev.target.result); };
            reader.readAsDataURL(file);
        }
    }
    async def save_event() {
        if len(title.strip()) == 0 or len(university.strip()) == 0 {
            status = "Enter an event name and university before saving.";
            return;
        }
        username = localStorage.getItem("uv_admin_user") or "";
        password = localStorage.getItem("uv_admin_pass") or "";
        price_value = int(price) if price != "" else 0;
        event_id = editing_id if editing_id != "" else "event-" + str(len(events) + 1);
        if category == "Educational" { price_value = 0; }
        item: dict = {"id": event_id, "title": title, "category": category, "university": university, "event_date": date, "date_label": date_label, "time": time, "venue": venue, "description": description, "sport": "", "price": price_value, "seats": 100, "live": False, "zoom_url": detail_link, "thumbnail": thumbnail, "additional_info": additional_info, "deadline": deadline, "buy_url": buy_url, "visibility": visibility};
        result: Event | None = None;
        try {
            if editing_id == "" { result = await create_event(username, password, item); }
            else { result = await update_event(username, password, item); }
            if result is None {
                status = "Event save was rejected. Check admin credentials and required details.";
                return;
            }
            events = await admin_list_events(username, password);
            status = "Event added successfully." if editing_id == "" else "Event updated successfully.";
            title = ""; description = ""; detail_link = ""; additional_info = ""; deadline = ""; buy_url = ""; editing_id = ""; thumbnail = "";
        } except Exception {
            status = "Event could not reach the server. Please retry; image uploads must be under 450 KB.";
        }
    }
    async def delete_event(event_id: str) {
        username = localStorage.getItem("uv_admin_user") or "";
        password = localStorage.getItem("uv_admin_pass") or "";
        removed: bool = False;
        removed = await remove_event(username, password, event_id);
        events = await admin_list_events(username, password);
        status = "Event removed." if removed else "Could not remove event.";
    }
    def edit_event(event: Event) {
        editing_id = event.id; title = event.title; category = event.category; university = event.university; date = event.event_date; date_label = event.date_label; time = event.time; venue = event.venue; description = event.description; price = str(event.price); detail_link = event.zoom_url; thumbnail = event.thumbnail; additional_info = event.additional_info; deadline = event.deadline; buy_url = event.buy_url; visibility = event.visibility;
    }
    def sign_out(e: MouseEvent) { localStorage.removeItem("uv_admin_user"); localStorage.removeItem("uv_admin_pass"); nav("/universe-admin"); }
    return <main className="min-h-screen bg-muted/40"><header className="border-b bg-background"><div className="mx-auto flex h-16 max-w-7xl items-center justify-between px-5 sm:px-8"><Link to="/" className="text-2xl font-extrabold"><span className="text-[#090a47]">Uni</span><span className="text-[#6e101d]">Verse</span></Link><div className="flex items-center gap-4"><Link to="/universe-admin/applications" className="text-sm font-medium text-primary">Student applications</Link><span className="text-sm text-muted-foreground">Event management</span><Button variant="outline" size="sm" onClick={sign_out}>Sign out</Button></div></div></header><div className="mx-auto max-w-7xl px-5 py-10 sm:px-8"><div><p className="text-sm font-semibold text-primary">ADMIN WORKSPACE</p><h1 className="mt-2 text-3xl font-semibold tracking-tight">Manage campus events</h1><p className="mt-2 text-sm text-muted-foreground">Create, update, and remove event listings.</p></div><div className="mt-8 grid gap-6 lg:grid-cols-[0.85fr_1.15fr]"><Card className="h-fit shadow-sm"><CardContent className="flex flex-col gap-4 p-5"><h2 className="text-xl font-semibold">{ "Edit event" if editing_id != "" else "Add an event" }</h2><label className="flex flex-col gap-1.5 text-sm font-medium">Event name<Input value={title} onChange={on_title} placeholder="Campus event name" /></label><div className="grid grid-cols-2 gap-3"><label className="flex flex-col gap-1.5 text-sm font-medium">Category<select value={category} onChange={on_category} className="h-10 rounded-lg border bg-background px-3"><option>Educational</option><option>Sports</option><option>Entertainment</option><option>Merch</option></select></label>{category != "Educational" and <label className="flex flex-col gap-1.5 text-sm font-medium">Price in LKR<Input type="number" min="0" value={price} onChange={on_price} /></label>}</div><label className="flex flex-col gap-1.5 text-sm font-medium">University<Input value={university} onChange={on_university} /></label><label className="flex flex-col gap-1.5 text-sm font-medium">Who can attend?<select value={visibility} onChange={on_visibility} className="h-10 rounded-lg border bg-background px-3"><option>Public</option><option>Private</option></select><span className="text-xs font-normal text-muted-foreground">Private events are visible only on the matching university page.</span></label><div className="grid grid-cols-2 gap-3"><label className="flex flex-col gap-1.5 text-sm font-medium">Event date<Input type="date" value={date} onChange={on_date} /></label><label className="flex flex-col gap-1.5 text-sm font-medium">Date label<Input value={date_label} onChange={on_date_label} placeholder="NOV 20" /></label></div><div className="grid grid-cols-2 gap-3"><label className="flex flex-col gap-1.5 text-sm font-medium">Time<Input value={time} onChange={on_time} /></label><label className="flex flex-col gap-1.5 text-sm font-medium">Venue<Input value={venue} onChange={on_venue} /></label></div><label className="flex flex-col gap-1.5 text-sm font-medium">Brief description<textarea value={description} onChange={on_description} rows={3} placeholder="Short event summary" className="rounded-lg border bg-background px-3 py-2 text-sm" /></label><label className="flex flex-col gap-1.5 text-sm font-medium">Additional popup information<textarea value={additional_info} onChange={on_additional_info} rows={4} placeholder="Agenda, longer details, access notes, etc." className="rounded-lg border bg-background px-3 py-2 text-sm" /></label><label className="flex flex-col gap-1.5 text-sm font-medium">Online or additional info link<Input type="url" value={detail_link} onChange={on_link} placeholder="https://..." /></label>{category == "Merch" and <label className="flex flex-col gap-1.5 text-sm font-medium">Merch order deadline<Input type="date" value={deadline} onChange={on_deadline} /></label>}{category == "Merch" and <label className="flex flex-col gap-1.5 text-sm font-medium">Google Form buy link<Input type="url" value={buy_url} onChange={on_buy_url} placeholder="https://forms.gle/..." /></label>}<label className="flex flex-col gap-2 text-sm font-medium">Thumbnail image<input type="file" accept="image/*" onChange={on_file} className="block w-full text-sm file:mr-3 file:rounded-full file:border-0 file:bg-primary/10 file:px-4 file:py-2 file:font-medium file:text-primary" />{thumbnail and <img src={thumbnail} alt="Event thumbnail preview" className="h-28 w-full rounded-xl object-cover" />}</label><Button onClick={save_event}>{"Save changes" if editing_id != "" else "Add event"}</Button>{status and <p className="text-sm text-primary">{status}</p>}</CardContent></Card><section className="flex flex-col gap-3"><div className="flex items-center justify-between"><h2 className="text-xl font-semibold">Event listings</h2><span className="text-sm text-muted-foreground">{str(len(events))} events</span></div>{if len(events) == 0 {<Card className="border-dashed py-10 text-center"><CardContent><p className="font-medium">No events yet</p><p className="mt-1 text-sm text-muted-foreground">Add an event to publish it to UniVerse.</p></CardContent></Card>; skip;}}{for event in events {<Card key={event.id} className="shadow-sm"><CardContent className="flex flex-wrap items-center gap-4 p-4">{event.thumbnail and <img src={event.thumbnail} alt="" className="size-16 rounded-lg object-cover" />}<div className="min-w-40 flex-1"><h3 className="font-semibold">{event.title}</h3><p className="mt-1 text-sm text-muted-foreground">{event.university} · {event.date_label} · {event.visibility} · LKR {str(event.price)}</p></div><Button variant="outline" size="sm" onClick={lambda (e: MouseEvent) { edit_event(event); }}>Edit</Button><Button variant="outline" size="sm" onClick={lambda (e: MouseEvent) { delete_event(event.id); }}>Remove</Button></CardContent></Card>}}</section></div></div></main>;
}
