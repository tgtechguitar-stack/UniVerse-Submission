import from datetime { datetime }
import from uuid { uuid4 }
import from datetime { datetime }

obj StudentApplicationRecord {
    has id: str;
    has full_name: str;
    has university: str;
    has proof_image: str;
    has batch: str;
    has birthday: str;
    has submitted_at: str;
    has status: str = "Pending";
    has payment_status: str = "Unpaid";
}

node StudentVerification {
    has full_name: str;
    has university: str;
    has proof_image: str;
    has batch: str;
    has birthday: str;
    has submitted_at: str;
    has status: str = "Pending";
    has payment_status: str = "Unpaid";
}

def _is_admin(username: str, password: str) -> bool {
    import os;
    expected_user = os.getenv("UNIVERSE_ADMIN_USERNAME", "");
    expected_password = os.getenv("UNIVERSE_ADMIN_PASSWORD", "");
    return len(expected_user) > 0 and len(expected_password) > 0 and username == expected_user and password == expected_password;
}

def:pub submit_student_application(full_name: str, university: str, proof_image: str, batch: str, birthday: str) -> StudentApplicationRecord | None {
    if len(full_name.strip()) == 0 or len(university.strip()) == 0 or len(batch.strip()) == 0 or len(birthday) != 10 or not proof_image.startswith("data:image/") or len(proof_image) > 700000 {
        return None;
    }
    submitted_at = str(datetime.now());
    id = str(uuid4());
    record = root.shared ++> StudentVerification(full_name=full_name.strip(), university=university.strip(), proof_image=proof_image, batch=batch.strip(), birthday=birthday, submitted_at=submitted_at);
    return StudentApplicationRecord(id=jid(record), full_name=record.full_name, university=record.university, proof_image=record.proof_image, batch=record.batch, birthday=record.birthday, submitted_at=record.submitted_at, status=record.status);
}

def:pub admin_list_applications(username: str, password: str) -> list[StudentApplicationRecord] {
    if not _is_admin(username, password) { return []; }
    return [StudentApplicationRecord(id=jid(app), full_name=app.full_name, university=app.university, proof_image=app.proof_image, batch=app.batch, birthday=app.birthday, submitted_at=app.submitted_at, status=app.status, payment_status=app.payment_status) for app in [root.shared -->][?:StudentVerification]];
}

def:pub review_student_application(username: str, password: str, application_id: str, decision: str) -> bool {
    if not _is_admin(username, password) or (decision != "Approved" and decision != "Rejected") { return False; }
    for app in [root.shared -->][?:StudentVerification] {
        if jid(app) == application_id {
            app.status = decision;
            return True;
        }
    }
    return False;
}

def:pub confirm_membership_payment(username: str, password: str, application_id: str) -> bool {
    if not _is_admin(username, password) { return False; }
    for app in [root.shared -->][?:StudentVerification] {
        if jid(app) == application_id and app.status == "Approved" {
            app.payment_status = "Paid";
            return True;
        }
    }
    return False;
}

def:pub verification_status(application_id: str) -> str {
    for app in [root.shared -->][?:StudentVerification] {
        if jid(app) == application_id { return app.status + " / " + app.payment_status; }
    }
    return "Not found";
}

def:pub member_university(application_id: str) -> str {
    for app in [root.shared -->][?:StudentVerification] {
        if jid(app) == application_id and app.status == "Approved" and app.payment_status == "Paid" { return app.university; }
    }
    return "";
}

def:pub member_has_access(application_id: str) -> bool {
    for app in [root.shared -->][?:StudentVerification] {
        if jid(app) == application_id and app.status == "Approved" and app.payment_status == "Paid" { return True; }
    }
    return False;
}


