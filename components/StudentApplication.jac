import from ..services.student_verification { StudentApplicationRecord, submit_student_application }
import from .ui.card { Card, CardContent }
import from .ui.button { Button }
import from .ui.input { Input }
import from "@jac/runtime" { Link }

glob APPLICATION_UNIVERSITIES: list[str] = ["University of Colombo", "University of Peradeniya", "University of Sri Jayewardenepura", "University of Kelaniya", "University of Moratuwa", "University of Jaffna", "University of Ruhuna", "The Open University of Sri Lanka", "Eastern University, Sri Lanka", "South Eastern University of Sri Lanka", "Rajarata University of Sri Lanka", "Sabaragamuwa University of Sri Lanka", "Wayamba University of Sri Lanka", "Uva Wellassa University of Sri Lanka", "University of the Visual and Performing Arts", "Gampaha Wickramarachchi University of Indigenous Medicine", "University of Vavuniya", "General Sir John Kotelawala Defence University", "Buddhist and Pali University of Sri Lanka", "Bhiksu University of Sri Lanka", "University of Vocational Technology", "Ocean University of Sri Lanka", "National Institute of Business Management", "Institute of Surveying and Mapping", "National Institute of Social Development", "Sri Lanka Institute of Development"];

 def:pub StudentApplication() -> JsxElement {
    has full_name: str = "";
    has university: str = "";
    has batch: str = "";
    has birthday: str = "";
    has proof_image: str = "";
    has result_message: str = "";
    has submitted: bool = False;
    has submitting: bool = False;
    has application_reference: str = "";

    def on_full_name(e: ChangeEvent) { full_name = e.target.value; }
    def on_university(e: ChangeEvent) { university = e.target.value; }
    def on_batch(e: ChangeEvent) { batch = e.target.value; }
    def on_birthday(e: ChangeEvent) { birthday = e.target.value; }
    def on_proof(e: ChangeEvent) {
        files: any = e.target.files;
        file: any = files[0];
        if file {
            if str(file.type).startswith("image/") and (file.size as int) <= 450000 {
                reader: any = new(FileReader as type);
                reader.onload = lambda (ev: any) { proof_image = str(ev.target.result); };
                reader.readAsDataURL(file);
                result_message = "";
            } else { result_message = "Choose an image file under 450 KB so it can upload reliably."; }
        }
    }
    async def submit_application() {
        if len(full_name.strip()) == 0 or len(university) == 0 or len(batch.strip()) == 0 or len(birthday) != 10 or proof_image == "" {
            result_message = "Complete every field and upload a clear university ID photo.";
        } else {
            submitting = True;
            record: StudentApplicationRecord | None = None;
            try {
                record = await submit_student_application(full_name, university, proof_image, batch, birthday);
                if record is not None {
                    localStorage.setItem("uv_university", record.university);
                    localStorage.setItem("uv_application_id", record.id);
                    application_reference = record.id;
                    localStorage.setItem("uv_verified", "false");
                    localStorage.setItem("uv_paid", "false");
                    submitted = True;
                    result_message = "Your application has been submitted for verification. An administrator will review your university details. Access to university pages will unlock after verification and membership payment.";
                } else { result_message = "The application was not accepted. Upload a smaller image (under 450 KB) and check all fields."; }
            } except Exception {
                result_message = "Submission failed to reach the server. Please try again with an ID photo under 450 KB.";
            }
            submitting = False;
        }
    }

    message_class = "rounded-xl bg-amber-50 p-3 text-sm text-amber-900";
    if submitted { message_class = "rounded-xl bg-emerald-50 p-3 text-sm text-emerald-900"; }

    return <main className="min-h-screen bg-muted/40">
        <header className="border-b bg-background"><div className="mx-auto flex h-16 max-w-6xl items-center justify-between px-5 sm:px-8"><Link to="/" className="text-2xl font-extrabold"><span className="text-[#090a47]">Uni</span><span className="text-[#6e101d]">Verse</span></Link><Link to="/" className="text-sm font-medium text-muted-foreground hover:text-foreground">Back to events</Link></div></header>
        <section className="mx-auto grid max-w-6xl gap-8 px-5 py-10 sm:px-8 lg:grid-cols-[0.8fr_1.2fr] lg:py-14">
            <div className="flex flex-col justify-between rounded-3xl bg-[#172a4d] p-7 text-white shadow-xl sm:p-10"><div><p className="text-sm font-semibold text-blue-200">YOUR CAMPUS, YOUR COMMUNITY</p><h1 className="mt-4 text-4xl font-semibold leading-tight">Get verified. Find your people.</h1><p className="mt-4 leading-relaxed text-blue-100">Tell us a little about yourself and upload your student ID so our team can verify your university membership.</p></div><div className="mt-10 rounded-2xl border border-white/15 bg-white/10 p-5"><p className="font-semibold">What happens next?</p><p className="mt-2 text-sm leading-relaxed text-blue-100">Your application is reviewed by an administrator. You’ll see a submission confirmation as soon as it’s received.</p></div></div>
            <Card className="shadow-sm"><CardContent className="flex flex-col gap-5 p-6 sm:p-8">
                {submitted and <div className="rounded-2xl border border-emerald-200 bg-emerald-50 p-5 text-emerald-900"><p className="text-lg font-semibold">Submitted for verification</p><p className="mt-1 text-sm leading-relaxed">Your details are with our admin team for review. Your request is marked pending verification.</p><p className="mt-2 text-xs font-medium">Application reference: {application_reference}</p></div>}
                <div><p className="text-sm font-semibold text-primary">STUDENT APPLICATION</p><h2 className="mt-2 text-2xl font-semibold tracking-tight">Create your account</h2><p className="mt-1 text-sm text-muted-foreground">Use the information shown on your university ID.</p></div>
                <label className="flex flex-col gap-1.5 text-sm font-medium">Full name<Input value={full_name} onChange={on_full_name} placeholder="Name as shown on your ID" disabled={submitted} /></label>
                <label className="flex flex-col gap-1.5 text-sm font-medium">University<select value={university} onChange={on_university} disabled={submitted} className="h-11 w-full rounded-xl border border-border bg-background px-3 text-sm"><option value="">Select your university</option><optgroup label="Government universities">{for name in APPLICATION_UNIVERSITIES {<option key={name} value={name}>{name}</option>}}</optgroup></select></label>
                <div className="grid gap-4 sm:grid-cols-2"><label className="flex flex-col gap-1.5 text-sm font-medium">Batch<Input value={batch} onChange={on_batch} placeholder="For example, 2024" disabled={submitted} /></label><label className="flex flex-col gap-1.5 text-sm font-medium">Birthday<Input type="date" value={birthday} onChange={on_birthday} disabled={submitted} /></label></div>
                <label className="flex flex-col gap-2 text-sm font-medium">University ID photo<span className="text-xs font-normal text-muted-foreground">Upload a clear image of your student ID. JPG, PNG or another image format, up to 2.5 MB.</span><input type="file" accept="image/*" onChange={on_proof} disabled={submitted} className="block w-full rounded-xl border border-dashed border-border bg-muted/30 p-3 text-sm file:mr-3 file:rounded-full file:border-0 file:bg-primary/10 file:px-4 file:py-2 file:font-medium file:text-primary" />{proof_image and <img src={proof_image} alt="Preview of uploaded university ID" className="max-h-52 w-fit rounded-xl border object-contain" />}</label>
                {not submitted and <Button onClick={submit_application} disabled={submitting} className="h-11">{"Submitting application…" if submitting else "Submit for verification"}</Button>}
                {result_message and <p className={message_class}>{result_message}</p>}
            </CardContent></Card>
        </section>
    </main>;
}
