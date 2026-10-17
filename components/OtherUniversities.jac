import from ..services.events { Event, list_events }
import from ..services.student_verification { member_has_access }
import from .ui.card { Card, CardContent }
import from "@jac/runtime" { Link }

glob GOVERNMENT_UNIVERSITIES: list[str] = [
    "University of Colombo",
    "University of Peradeniya",
    "University of Sri Jayewardenepura",
    "University of Kelaniya",
    "University of Moratuwa",
    "University of Jaffna",
    "University of Ruhuna",
    "The Open University of Sri Lanka",
    "Eastern University, Sri Lanka",
    "South Eastern University of Sri Lanka",
    "Rajarata University of Sri Lanka",
    "Sabaragamuwa University of Sri Lanka",
    "Wayamba University of Sri Lanka",
    "Uva Wellassa University of Sri Lanka",
    "University of the Visual and Performing Arts",
    "Gampaha Wickramarachchi University of Indigenous Medicine",
    "University of Vavuniya",
    "General Sir John Kotelawala Defence University",
    "Buddhist and Pali University of Sri Lanka",
    "Bhiksu University of Sri Lanka",
    "University of Vocational Technology",
    "Ocean University of Sri Lanka",
    "National Institute of Business Management",
    "Institute of Surveying and Mapping",
    "National Institute of Social Development",
    "Sri Lanka Institute of Development"
];

glob PRIVATE_INSTITUTIONS: list[str] = [
    "Sri Lanka Institute of Information Technology (SLIIT)",
    "National School of Business Management (NSBM Green University)",
    "Sri Lanka Technological Campus (SLTC Research University)",
    "Colombo International Nautical and Engineering College (CINEC Campus)",
    "Horizon Campus",
    "ESOFT Uni",
    "KAATSU International University (KIU)",
    "Saegis Campus",
    "International College of Business and Technology (ICBT Campus)",
    "Benedict XVI Catholic Institute of Higher Education (BCI Campus)",
    "Aquinas College of Higher Studies",
    "Nagananda International Institute for Buddhist Studies (NIIBS)",
    "Sri Lanka International Buddhist Academy (SIBA Campus)",
    "SANASA Campus",
    "Business Management School (BMS)",
    "Institute of Chemistry Ceylon (IChemC)",
    "Institute of Chartered Accountants of Sri Lanka (SAB Campus)",
    "Sri Lanka Institute of Nanotechnology (SLINTEC Academy)",
    "Informatics Institute of Technology (IIT)",
    "Asia Pacific Institute of Information Technology (APIIT)",
    "Royal Institute of Colombo (RIC)",
    "Curtin Colombo",
    "Edith Cowan University (ECU) Sri Lanka",
    "Universal College Lanka (UCL)",
    "Australian College of Business and Technology (ACBT)",
    "ANC Education",
    "British College of Applied Studies (BCAS Campus)",
    "Management and Science Institute (MSI)",
    "International Institute of Health Sciences (IIHS)",
    "Spectrum Institute of Science and Technology (SIST)",
    "Imperial Institute of Higher Education (IIHE)"
];

def:pub OtherUniversities() -> JsxElement {
    has events: list[Event] = [];
    has selected: str = "All universities";
    has has_access: bool = False;

    async can with entry {
        application_id = localStorage.getItem("uv_application_id") or "";
        if application_id != "" { has_access = await member_has_access(application_id); }
        events = await list_events();
    }

    def handle_university(e: ChangeEvent) {
        selected = e.target.value;
    }

    shown = [event for event in events if selected == "All universities" or event.university == selected];

    return <main className="min-h-screen bg-muted/40">
        <header className="border-b bg-background">
            <div className="mx-auto flex h-16 max-w-7xl items-center justify-between px-5 sm:px-8">
                <Link to="/" className="text-2xl font-extrabold"><span className="text-[#090a47]">Uni</span><span className="text-[#6e101d]">Verse</span></Link>
                <nav className="flex gap-5 text-sm"><Link to="/">My university</Link><span className="font-semibold text-primary">Other universities</span></nav>
            </div>
        </header>
        <section className="mx-auto max-w-7xl px-5 py-12 sm:px-8">
            {if not has_access {<Card className="mx-auto max-w-2xl shadow-sm"><CardContent className="flex flex-col gap-4 p-7"><p className="text-sm font-semibold text-primary">MEMBER ACCESS</p><h1 className="text-3xl font-semibold">Unlock university-wide discovery</h1><p className="text-muted-foreground">Create your account, get verified with a student ID, and complete membership payment to access campus events from other universities.</p><Link to="/apply" className="inline-flex h-11 w-fit items-center rounded-full bg-primary px-5 text-sm font-semibold text-primary-foreground">Create student account</Link></CardContent></Card>; skip;}}
            <p className="text-sm font-semibold text-primary">EXPLORE BEYOND YOUR CAMPUS</p>
            <h1 className="mt-2 text-4xl font-semibold tracking-tight">Other universities</h1>
            <p className="mt-2 text-muted-foreground">Discover events hosted across Sri Lanka's university community.</p>
            <div className="mt-7 flex w-full max-w-xl flex-col gap-2">
                <label htmlFor="university-filter" className="text-sm font-semibold">Choose a university</label>
                <select id="university-filter" value={selected} onChange={handle_university} className="h-12 w-full rounded-xl border border-border bg-card px-4 text-sm shadow-sm focus:outline-none focus:ring-2 focus:ring-ring">
                    <option value="All universities">All universities</option>
                    <optgroup label="Government universities">{for university in GOVERNMENT_UNIVERSITIES {<option key={university} value={university}>{university}</option>}}</optgroup><optgroup label="Private and non-state institutions">{for university in PRIVATE_INSTITUTIONS {<option key={university} value={university}>{university}</option>}}</optgroup>
                </select>
            </div>
            <div className="mt-8 grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
                {if len(shown) == 0 {
                    <Card className="col-span-full border-dashed py-12 text-center"><CardContent><h2 className="text-lg font-semibold">More campus events are on the way</h2><p className="mt-2 text-sm text-muted-foreground">There are no events for this selection yet. Choose another university or check back soon.</p></CardContent></Card>;
                    skip;
                }}
                {for event in shown {
                    <Card key={event.id} className="overflow-hidden shadow-sm transition-shadow hover:shadow-md"><div className="h-32 bg-gradient-to-br from-blue-300 via-indigo-500 to-slate-900"></div><CardContent className="flex flex-col gap-2 p-5"><p className="text-xs font-semibold uppercase text-primary">{event.university} · {event.date_label}</p><h2 className="text-lg font-semibold">{event.title}</h2><p className="text-sm text-muted-foreground">{event.description}</p><p className="mt-2 font-semibold">{"LKR " + str(event.price) if event.price > 0 else "Free entry"}</p></CardContent></Card>
                }}
            </div>
        </section>
    </main>;
}
