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
<html>
<head>
    <title>Sucursal - <%= nombreSucursal %></title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body>
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

<h4>PRODUCTOS DE LA SUCURSAL: <%= nombreSucursal %></h4>
<p>Domicilio: <%= domicilio %></p>

<%
            while (listaProductos.next()) {
                int costoprod = Integer.parseInt(listaProductos.getString("stock")) * Integer.parseInt(listaProductos.getString("precio"));
                costototal = costototal + costoprod;
%>

<ul>
    <li>PRODUCTO: <%= listaProductos.getString("nombre") %></li>
    <li>DESCRIPCIÓN: <%= listaProductos.getString("descripcion") %></li>
    <li>CÓDIGO: <%= listaProductos.getString("codigo") %></li>
    <li>STOCK: <%= listaProductos.getString("stock") %></li>
    <li>PRECIO UNITARIO: <%= listaProductos.getString("precio") %></li>
    <li>COSTO TOTAL: <%= costoprod %></li>
</ul>

<%
            }
%>

<p>COSTO TOTAL DE TODOS LOS PRODUCTOS: <%= costototal %></p>

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

<br><br>
<a href="index.jsp" class="btn btn-white btn-circled">Volver</a>
</body>
</html>
