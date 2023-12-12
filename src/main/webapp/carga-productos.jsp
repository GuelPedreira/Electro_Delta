
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.DriverManager"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html>
<head>
    <%
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conexion = null;
        String SelectSuc = "select suc_id FROM sucs_tb WHERE denom = ?";
        PreparedStatement consultaSuc = null;
        ResultSet listaSucursal = null;

        try {
            conexion = DriverManager.getConnection("jdbc:mysql://localhost:3306/electrodelta", "root", "admin");
            consultaSuc = conexion.prepareStatement(SelectSuc);
            consultaSuc.setString(1,request.getParameter("id"));
            listaSucursal = consultaSuc.executeQuery();
            listaSucursal.next();
    %>
    <title><%out.print(listaSucursal.getString("denom"));%></title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body>
    <h3>Ingresá la información sobre el producto para sucursal:</h3>
    <h2><%out.print(listaSucursal.getString("denom"));%></h2>

    <form method="post" action="ingreso-productos.jsp">

        Producto <input type="text" name="producto"/><br/><br/>
        Descripción <input type="text" name="descripcion"/><br/><br/>
        Precio <input type="text" name="precio"/><br/><br/>
        Cantidad <input type="text" name="cantidad"/><br/><br/>
        Código <input type="text" name="codigo"/><br/>

        <input type="hidden" name="id_sucu" value="<%out.print(request.getParameter("id"));%>"/>

        <br/><br/>

        <input type="submit" value="Aceptar">

        <br/><br/>

        <a href="index.jsp" class="btn btn-white btn-circled">Volver</a>

    </form>
</body>
<%
    } catch (Exception e) {
        e.printStackTrace();
        out.println("Hubo un problema al cargar la página.");
    } finally {
        try {
            consultaSuc.close();
            conexion.close();
        } catch (Exception e) {
        }
    }
%>
</html>
