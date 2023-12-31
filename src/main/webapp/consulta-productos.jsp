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
    // Manejo de error: El par�metro 'sucursal' no est� presente en la URL.
    out.println("Error: El par�metro 'sucursal' no est� presente en la URL.");
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
            padding-top: 20px;
        }
        .banner {
            background-image: url('img/cambiar-electrodomesticos.jpg');
            background-size: cover;
            background-repeat: no-repeat;
            background-position: center;
            color: #fff;
            padding: 10px 10px; /* Ajusta el tama�o de la banda superior */
            text-align: center;
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

    <!-- Lista de productos en una tabla Bootstrap -->
    <div class="table-container">
        <table class="table">
            <thead>
                <tr>
                    <th>Nombre</th>
                    <th>Descripci�n</th>
                    <th>C�digo</th>
                    <th>Stock</th>
                    <th>Precio Unitario</th>
                    <th>Costo Total</th>
                </tr>
            </thead>
            <tbody>
                <% while (listaProductos.next()) { %>
                    <tr>
                        <td><%= listaProductos.getString("nombre") %></td>
                        <td><%= listaProductos.getString("descripcion") %></td>
                        <td><%= listaProductos.getString("codigo") %></td>
                        <td><%= listaProductos.getString("stock") %></td>
                        <td><%= listaProductos.getString("precio") %></td>
                        <td><%= Integer.parseInt(listaProductos.getString("stock")) * Integer.parseInt(listaProductos.getString("precio")) %></td>
                        <% costototal += Integer.parseInt(listaProductos.getString("stock")) * Integer.parseInt(listaProductos.getString("precio")); %>
                    </tr>
                <% } %>
            </tbody>
        </table>
    </div>

<!-- Costo total -->
<div class="container mt-3">
    <div class="row justify-content-center">
        <div class="col-md-6">
            <div id="total-cost-container" class="bg-secondary text-light p-4 rounded text-center d-flex align-items-center justify-content-center" style="height: 60px;">
                <p style="font-size: 18px; margin: 0;">COSTO TOTAL DE TODOS LOS PRODUCTOS: <%= costototal %></p>
            </div>
        </div>
    </div>
</div>


    <!-- Bot�n de volver -->
        <a href="index.jsp" class="volver">Volver</a>
</div>

<%
        } else {
            out.println("No se encontr� la sucursal.");
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

<!-- Scripts de Bootstrap (aseg�rate de tener Internet para cargar estos recursos) -->
<script src="https://code.jquery.com/jquery-3.3.1.slim.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.7/umd/popper.min.js"></script>
<script src="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/js/bootstrap.min.js"></script>

</body>
</html>