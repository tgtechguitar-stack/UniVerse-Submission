import from ..services.student_verification { StudentApplicationRecord, admin_list_applications, review_student_application, confirm_membership_payment }
import from .ui.card { Card, CardContent }
import from .ui.button { Button }
import from "@jac/runtime" { Link, useNavigate }

 def:pub AdminApplications() -> JsxElement {
    has applications: list[StudentApplicationRecord] = [];
    has status_message: str = "";
    has loading: bool = True;
    nav = useNavigate();

    async can with entry {
        username = localStorage.getItem("uv_admin_user") or "";
        password = localStorage.getItem("uv_admin_pass") or "";
        if username == "" or password == "" { nav("/universe-admin"); }
        else { applications = await admin_list_applications(username, password); }
        loading = False;
    }

    async def review(application_id: str, decision: str) {
        username = localStorage.getItem("uv_admin_user") or "";
        password = localStorage.getItem("uv_admin_pass") or "";
        ok: bool = False;
        ok = await review_student_application(username, password, application_id, decision);
        if ok {
            applications = await admin_list_applications(username, password);
            status_message = "Application " + decision.lower() + ".";
        } else { status_message = "Review could not be saved."; }
    }

    async def mark_paid(application_id: str) {
        username = localStorage.getItem("uv_admin_user") or "";
        password = localStorage.getItem("uv_admin_pass") or "";
        ok: bool = False;
        ok = await confirm_membership_payment(username, password, application_id);
        if ok {
            applications = await admin_list_applications(username, password);
            status_message = "Membership payment confirmed.";
        } else { status_message = "Approve the university verification before confirming payment."; }
    }

    def sign_out(e: MouseEvent) {
        localStorage.removeItem("uv_admin_user");
        localStorage.removeItem("uv_admin_pass");
        nav("/universe-admin");
    }

    return <main className="min-h-screen bg-muted/40">
        <header className="border-b bg-background"><div className="mx-auto flex h-16 max-w-7xl items-center justify-between px-5 sm:px-8"><Link to="/" className="text-2xl font-extrabold"><span className="text-[#090a47]">Uni</span><span className="text-[#6e101d]">Verse</span></Link><div className="flex items-center gap-3"><Link to="/universe-admin/events" className="text-sm font-medium text-muted-foreground">Events</Link><Button variant="outline" size="sm" onClick={sign_out}>Sign out</Button></div></div></header>
        <section className="mx-auto max-w-7xl px-5 py-10 sm:px-8"><p className="text-sm font-semibold text-primary">ADMIN WORKSPACE</p><h1 className="mt-2 text-3xl font-semibold tracking-tight">Student verification</h1><p className="mt-2 text-sm text-muted-foreground">Review university details and student ID photos before approving membership.</p>{status_message and <p className="mt-5 rounded-xl bg-primary/10 p-3 text-sm font-medium text-primary">{status_message}</p>}
            <div className="mt-8 flex flex-col gap-4">{if loading {<Card className="py-10 text-center text-muted-foreground"><CardContent>Loading verification requests…</CardContent></Card>; skip;}}{if len(applications) == 0 {<Card className="border-dashed py-12 text-center"><CardContent><h2 className="text-lg font-semibold">No applications to review</h2><p className="mt-2 text-sm text-muted-foreground">New student verification requests will appear here.</p></CardContent></Card>; skip;}}
                {for application in applications {<Card key={application.id} className="shadow-sm"><CardContent className="grid gap-5 p-5 md:grid-cols-[minmax(0,1fr)_260px]"><div className="flex flex-col gap-4"><div className="flex flex-wrap items-start justify-between gap-3"><div><h2 className="text-xl font-semibold">{application.full_name}</h2><p className="mt-1 text-sm text-muted-foreground">{application.university}</p></div><div className="flex flex-wrap gap-2"><span className={"rounded-full px-3 py-1 text-xs font-semibold " + ("bg-amber-100 text-amber-900" if application.status == "Pending" else "bg-emerald-100 text-emerald-900" if application.status == "Approved" else "bg-rose-100 text-rose-900")}>ID: {application.status}</span><span className={"rounded-full px-3 py-1 text-xs font-semibold " + ("bg-emerald-100 text-emerald-900" if application.payment_status == "Paid" else "bg-amber-100 text-amber-900")}>Membership: {application.payment_status}</span></div></div><dl className="grid gap-3 rounded-xl bg-muted/50 p-4 text-sm sm:grid-cols-2"><div><dt className="text-xs text-muted-foreground">BATCH</dt><dd className="mt-1 font-medium">{application.batch}</dd></div><div><dt className="text-xs text-muted-foreground">BIRTHDAY</dt><dd className="mt-1 font-medium">{application.birthday}</dd></div><div className="sm:col-span-2"><dt className="text-xs text-muted-foreground">SUBMITTED</dt><dd className="mt-1 font-medium">{application.submitted_at}</dd></div></dl>{application.status == "Pending" and <div className="flex flex-wrap gap-2"><Button onClick={lambda (e: MouseEvent) { review(application.id, "Approved"); }}>Approve student ID</Button><Button variant="outline" onClick={lambda (e: MouseEvent) { review(application.id, "Rejected"); }}>Reject</Button></div>}{application.status == "Approved" and application.payment_status != "Paid" and <Button variant="outline" onClick={lambda (e: MouseEvent) { mark_paid(application.id); }}>Confirm LKR 50 membership payment</Button>}</div><div className="flex flex-col gap-2"><p className="text-sm font-semibold">University ID proof</p><a href={application.proof_image} target="_blank" rel="noreferrer"><img src={application.proof_image} alt={"University ID photo submitted by " + application.full_name} className="max-h-64 w-full rounded-xl border bg-muted object-contain" /></a><a href={application.proof_image} target="_blank" rel="noreferrer" className="text-sm font-medium text-primary underline underline-offset-4">Open full-size photo</a></div></CardContent></Card>}}
            </div>
        </section>
    </main>;
}
