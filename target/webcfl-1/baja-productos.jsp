<%@ page import="java.sql.PreparedStatement"%>
<%@ page import="java.sql.ResultSet"%>
<%@ page import="java.sql.DriverManager"%>
<%@ page import="java.sql.Connection"%>
<%@ page contentType="text/html;charset=UTF-8"%>

<!DOCTYPE html>
<html>
<%
    Connection conexion = null;
    PreparedStatement consultaSuc = null;
    ResultSet listaSucursal = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conexion = DriverManager.getConnection("jdbc:mysql://localhost:3306/electrodelta", "root", "admin");

        String selectSuc = "SELECT denom FROM sucs_tb WHERE suc_id = ?";
        consultaSuc = conexion.prepareStatement(selectSuc);
        consultaSuc.setString(1, request.getParameter("id"));
        listaSucursal = consultaSuc.executeQuery();

        if (listaSucursal.next()) {
%>
<!DOCTYPE html>
<html>
<head>
    <title><%= listaSucursal.getString("denom") %></title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body>
    <h3>Ingresá el código del producto a eliminar de la sucursal:</h3>
    <h2><%= listaSucursal.getString("denom") %></h2>

    <form method="post" action="elimina-productos.jsp">
        <br/>
        Código <input type="text" name="codprod" required>
        <input type="hidden" name="id_sucu" value="<%= request.getParameter("id") %>">
        <br/><br/><br/>
        <input type="submit" value="Aceptar">
        <br/><br/>
        <a href="index.jsp" class="btn btn-white btn-circled">Volver</a>
    </form>
</body>
<%
        }
    } catch (Exception e) {
        // Manejo de excepciones
        e.printStackTrace();
        out.println("Hubo un problema al cargar la página.");
    } finally {
        // Cierre de recursos
        try {
            if (listaSucursal != null) listaSucursal.close();
            if (consultaSuc != null) consultaSuc.close();
            if (conexion != null) conexion.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
%>
</html>
