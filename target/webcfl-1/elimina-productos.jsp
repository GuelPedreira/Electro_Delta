<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.DriverManager"%>
<%@page import="java.sql.Connection"%>
<%@page contentType="text/html;charset=UTF-8"%>
<!DOCTYPE html>
<html>
<%
    Connection conexion = null;
    PreparedStatement consultaProd = null;
    PreparedStatement consultaSuc = null;
    ResultSet listaProducto = null;
    ResultSet listaSucursal = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conexion = DriverManager.getConnection("jdbc:mysql://localhost:3306/electrodelta", "root", "admin");

        String selectProd = "SELECT prod_id FROM prod_tb WHERE cod = ?";
        String selectSuc = "SELECT denom FROM sucs_tb WHERE suc_id = ?";

        consultaProd = conexion.prepareStatement(selectProd);
        consultaSuc = conexion.prepareStatement(selectSuc);

        consultaProd.setString(1, request.getParameter("codprod"));
        consultaSuc.setString(1, request.getParameter("id_sucu"));

        listaProducto = consultaProd.executeQuery();
        listaProducto.next();
        
        listaSucursal = consultaSuc.executeQuery();
        listaSucursal.next();
%>
<head>
    <title><%= listaSucursal.getString("denom") %></title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>

<body>
    <h2><%= listaSucursal.getString("denom") %></h2>

    <%
        String deleteProd = "DELETE FROM prod_suc WHERE sucu_id = ? AND produc_id = ?";

        try (PreparedStatement bajaProd = conexion.prepareStatement(deleteProd)) {
            bajaProd.setString(1, request.getParameter("id_sucu"));
            bajaProd.setInt(2, listaProducto.getInt("prod_id"));
            bajaProd.executeUpdate();
            
            out.print("PRODUCTO ELIMINADO");

        } catch (Exception e) {
            // Manejo de excepciones
            e.printStackTrace();
            out.println("Hubo un problema al eliminar el producto.");
            out.println("Detalle de la consulta:");
            out.println(deleteProd + "<br/>");
        }
    %>

    <br/><br/>

    <a href="index.jsp" class="btn btn-white btn-circled">Volver</a>

</body>
<%
    } catch (Exception e) {
        // Manejo de excepciones
        e.printStackTrace();
        out.println("Hubo un problema al cargar la página.");
    } finally {
        // Cierre de recursos
        try {
            if (listaProducto != null) listaProducto.close();
            if (consultaProd != null) consultaProd.close();
            if (listaSucursal != null) listaSucursal.close();
            if (consultaSuc != null) consultaSuc.close();
            if (conexion != null) conexion.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
%>
</html>
