<%@ page import="java.io.*,java.util.*,javax.servlet.*"%>
<%@ page import="javax.servlet.http.*"%>
<%@ page import="java.sql.Connection"%>
<%@ page import="java.sql.PreparedStatement"%>
<%@ page import="java.sql.ResultSet"%>
<%@ page import="java.sql.DriverManager"%>
<%@ page import="java.sql.SQLException"%>

<%
String nombreSucursal = request.getParameter("sucursal");
if (nombreSucursal == null || nombreSucursal.isEmpty()) {
    // Manejo de error: El parámetro 'sucursal' no está presente en la URL.
    out.println("Error: El parámetro 'sucursal' no está presente en la URL.");
    return;
}
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <title>Sucursal - <%= nombreSucursal %></title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css">
    
    <style>
        body {
            margin: 0;
            padding: 0;
        }

        .banner {
            background-image: url('img/cambiar-electrodomesticos.jpg');
            background-size: cover;
            background-repeat: no-repeat;
            background-position: center;
            color: #fff;
            padding: 10px 10px; /* Ajusta el tamaño de la banda superior */
            text-align: center;
            font-weight: 600;
            font-size: 20px;
        }

        .table-container {
            margin-top: 20px;
        }

        #total-cost-container {
            margin-top: 20px;
        }        
                
        .volver {
            position: fixed;
            bottom: 20px;
            right: 20px;
            background-color: #195fc7;
            color: #ffffff;
            padding: 10px 20px;
            border-radius: 5px;
            text-decoration: none;
        }

    </style>

</head>
<body style="background-color: #CCCCCC;">

<%
    Connection conexion = null;
    PreparedStatement consultaSucursal = null;
    PreparedStatement consultaProductos = null;
    ResultSet resultadoSucursal = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conexion = DriverManager.getConnection("jdbc:mysql://localhost:3306/electrodelta", "root", "admin");

        // Obtener el suc_id de la sucursal
        String sucursalQuery = "SELECT suc_id, domic FROM sucs_tb WHERE denom = ?";
        consultaSucursal = conexion.prepareStatement(sucursalQuery);
        consultaSucursal.setString(1, nombreSucursal);

        resultadoSucursal = consultaSucursal.executeQuery();

        if (resultadoSucursal.next()) {
            String sucursalId = resultadoSucursal.getString("suc_id");
            String domicilio = resultadoSucursal.getString("domic");

            // Preparar la consulta de productos
            String productosQuery = "SELECT prod_tb.nom_prod AS nombre, prod_tb.descrip AS descripcion, " +
                    "prod_tb.cod AS codigo, prod_tb.precio AS precio, prod_suc.stock AS stock FROM prod_suc " +
                    "JOIN prod_tb ON prod_tb.prod_id = prod_suc.produc_id " +
                    "WHERE prod_suc.sucu_id=?";

            // Consultar los productos de la sucursal
            consultaProductos = conexion.prepareStatement(productosQuery);
            consultaProductos.setString(1, sucursalId);
            ResultSet listaProductos = consultaProductos.executeQuery();

            int costototal = 0;
%>

<div class="container">
    <!-- Banner -->
    <div class="banner">
        <h1>PRODUCTOS DE LA SUCURSAL: <%= nombreSucursal %></h1>
        <p>Domicilio: <%= domicilio %></p>
    </div>

<div class="table-container">
    <table class="table">
        <thead>
            <tr>
                <th>Nombre</th>
                <th>Descripción</th>
                <th>Código</th>
                <th>Stock</th>
                <th>Precio Unitario</th>
                <th>Costo Total</th>
                <th>Acciones</th> <!-- Nueva columna para el botón de eliminar -->
            </tr>
        </thead>
        <tbody>
            <% while (listaProductos.next()) { %>
                <tr class="producto-row"> <!-- Agrega una clase a la fila -->
                    <td><%= listaProductos.getString("nombre") %></td>
                    <td><%= listaProductos.getString("descripcion") %></td>
                    <td><%= listaProductos.getString("codigo") %></td>
                    <td><%= listaProductos.getString("stock") %></td>
                    <td><%= listaProductos.getString("precio") %></td>
                    <td><%= Integer.parseInt(listaProductos.getString("stock")) * Integer.parseInt(listaProductos.getString("precio")) %></td>
                    <% costototal += Integer.parseInt(listaProductos.getString("stock")) * Integer.parseInt(listaProductos.getString("precio")); %>
                    <td class="producto-row-eliminar">
                        <!-- Formulario para enviar la solicitud de eliminación al servidor -->
                        <form method="post" action="elimina-productos.jsp">
                            <input type="hidden" name="sucursal" value="<%= nombreSucursal %>">
                            <input type="hidden" name="productoCodigo" value="<%= listaProductos.getString("codigo") %>">
                            <button type="submit" class="btn btn-danger">Eliminar</button>
                        </form>
                    </td>
                </tr>
            <% } %>
        </tbody>
    </table>
</div>

    <!-- Botón de volver -->
    <a href="index.jsp" class="volver">Volver</a>
</div>

<%
        } else {
            out.println("No se encontró la sucursal.");
        }
    } catch (ClassNotFoundException | SQLException e) {
        e.printStackTrace();
        out.println("Hubo un problema al recuperar los productos.");
    } finally {
        // Cierre de recursos
        try {
            if (conexion != null) {
                conexion.close();
            }
            if (consultaSucursal != null) {
                consultaSucursal.close();
            }
            if (consultaProductos != null) {
                consultaProductos.close();
            }
            if (resultadoSucursal != null) {
                resultadoSucursal.close();
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
    }
%>

<!-- Scripts de Bootstrap (asegúrate de tener Internet para cargar estos recursos) -->
<script src="https://code.jquery.com/jquery-3.3.1.slim.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.7/umd/popper.min.js"></script>
<script src="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/js/bootstrap.min.js"></script>

</body>
</html>
