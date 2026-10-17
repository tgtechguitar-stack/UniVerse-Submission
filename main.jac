import from services.events { Event, list_events, reserve_ticket, list_universities, admin_login, admin_list_events, create_event, update_event, remove_event, upload_event_thumbnail, get_my_university_events }
import from services.student_verification { StudentApplicationRecord, submit_student_application, admin_list_applications, review_student_application, confirm_membership_payment, verification_status, member_university, member_has_access }
cl import from ".components.EventDiscovery" { EventDiscovery }
cl import from ".components.OtherUniversities" { OtherUniversities }
cl import from ".components.AdminLogin" { AdminLogin }
cl import from ".components.AdminEvents" { AdminEvents }
cl import from ".components.StudentApplication" { StudentApplication }
cl import from ".components.AdminApplications" { AdminApplications }
import ".styles/global.css";
import from "@jac/runtime" { Router, Routes, Route }

cl def:pub app() -> JsxElement {
    has dark_mode: bool = False;
    def toggle_theme(e: MouseEvent) {
        dark_mode = not dark_mode;
        if dark_mode { document.documentElement.classList.add("dark"); localStorage.setItem("uv_theme", "dark"); }
        else { document.documentElement.classList.remove("dark"); localStorage.setItem("uv_theme", "light"); }
    }
    async can with entry {
        stored = localStorage.getItem("uv_theme") or "light";
        dark_mode = stored == "dark";
        if dark_mode { document.documentElement.classList.add("dark"); }
    }
    return <div className="min-h-screen"><button onClick={toggle_theme} className="fixed bottom-5 right-5 z-50 rounded-full border border-border bg-card px-4 py-2 text-sm font-semibold shadow-lg" aria-label="Toggle light or dark theme">{"Light mode" if dark_mode else "Dark mode"}</button><Router><Routes><Route path="/" element={<EventDiscovery />} /><Route path="/universities" element={<OtherUniversities />} /><Route path="/universe-admin" element={<AdminLogin />} /><Route path="/universe-admin/events" element={<AdminEvents />} /><Route path="/apply" element={<StudentApplication />} /><Route path="/universe-admin/applications" element={<AdminApplications />} /></Routes></Router></div>;
}
