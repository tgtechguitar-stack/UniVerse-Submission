import from ..services.events { admin_login }
import from .ui.button { Button }
import from .ui.input { Input }
import from "@jac/runtime" { useNavigate, Link }

 def:pub AdminLogin() -> JsxElement {
    has username: str = "";
    has password: str = "";
    has message: str = "";
    nav = useNavigate();
    def handle_user(e: ChangeEvent) { username = e.target.value; }
    def handle_pass(e: ChangeEvent) { password = e.target.value; }
    async def sign_in() {
        ok: bool = False;
        ok = await admin_login(username, password);
        if ok {
            localStorage.setItem("uv_admin_user", username);
            localStorage.setItem("uv_admin_pass", password);
            nav("/universe-admin/events");
        } else { message = "Those admin credentials were not accepted."; }
    }
    return <main className="grid min-h-screen bg-background lg:grid-cols-2"><section className="hidden flex-col justify-between bg-[#172a4d] p-12 text-white lg:flex"><Link to="/" className="text-2xl font-extrabold"><span className="text-white">Uni</span><span className="text-rose-300">Verse</span></Link><div><p className="text-sm font-semibold text-blue-200">UNIVERSE ADMIN</p><h1 className="mt-4 max-w-lg text-5xl font-semibold leading-tight">Keep campus life moving.</h1><p className="mt-4 text-blue-100">Manage listings and make each event easy to discover.</p></div><p className="text-sm text-blue-200">Private event management</p></section><div className="flex items-center justify-center px-6 py-12"><div className="w-full max-w-sm"><Link to="/" className="text-sm text-muted-foreground">← Back to UniVerse</Link><h2 className="mt-10 text-3xl font-semibold">Admin sign in</h2><p className="mt-2 text-sm text-muted-foreground">No default admin account is created. In JacHammer Settings → Environment, set <strong>UNIVERSE_ADMIN_USERNAME</strong> and <strong>UNIVERSE_ADMIN_PASSWORD</strong> to your own secret values, then restart the preview.</p><div className="mt-8 flex flex-col gap-4"><label className="flex flex-col gap-2 text-sm font-medium">Username<Input value={username} onChange={handle_user} placeholder="Admin username" autoComplete="username" /></label><label className="flex flex-col gap-2 text-sm font-medium">Password<Input type="password" value={password} onChange={handle_pass} placeholder="Admin password" autoComplete="current-password" /></label><Button onClick={sign_in} className="mt-2 h-11">Sign in to manage events</Button>{message and <p className="text-sm text-destructive">{message}</p>}</div></div></div></main>;
}
