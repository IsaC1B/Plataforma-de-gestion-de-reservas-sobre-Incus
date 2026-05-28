const API_URL = "http://18.117.126.229:8000";

async function login() {

    const username =
        document.getElementById("username").value;

    const password =
        document.getElementById("password").value;

    const response = await fetch(
        `${API_URL}/auth/login`,
        {
            method: "POST",

            headers: {
                "Content-Type": "application/json"
            },

            body: JSON.stringify({
                username,
                password
            })
        }
    );

    const data = await response.json();

    console.log(data);

    document.getElementById("result")
        .textContent =
            JSON.stringify(data, null, 2);

    if (data.token) {

        localStorage.setItem(
            "token",
            data.token
        );

        window.location.href =
            "dashboard.html";
    }
}
