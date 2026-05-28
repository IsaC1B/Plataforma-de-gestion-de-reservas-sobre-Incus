const API_URL = "http://18.117.126.229:8000";

async function loadResources() {

    const token =
        localStorage.getItem("token");

    const response = await fetch(
        `${API_URL}/resources`,
        {
            headers: {
                Authorization: `Bearer ${token}`
            }
        }
    );

    const data = await response.json();

    console.log(data);

    let html = `
        <table class="table table-bordered">

            <tr>
                <th>ID</th>
                <th>Nombre</th>
                <th>Tipo</th>
                <th>Capacidad</th>
            </tr>
    `;

    data.forEach(resource => {

        html += `
            <tr>
                <td>${resource.id}</td>
                <td>${resource.name}</td>
                <td>${resource.resource_type}</td>
                <td>${resource.capacity}</td>
            </tr>
        `;
    });

    html += `</table>`;

    document.getElementById("resources")
        .innerHTML = html;
}
