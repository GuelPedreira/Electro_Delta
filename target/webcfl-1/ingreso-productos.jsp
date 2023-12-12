<%@page import="java.sql.Statement"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.DriverManager"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<%
    Class.forName("com.mysql.cj.jdbc.Driver");
    //SELET PARA CONSEGUIR LA DENOMINACION DE LA SUCURSAL
    String SelectSuc = "SELECT suc_id FROM sucs_tb WHERE denom = ?";
    //INSERT DE PRODUCTO
    String insert = "INSERT INTO prod_tb(nom_prod, descrip, cod, prod) VALUES (?,?,?,?)";
    //INSERT DE RELACION/ STOCK
    String insertStock = "INSERT INTO prod_suc(sucu_id, produc_id, stock) VALUES (?,(SELECT prod_id FROM prod_tb WHERE cod =?),?)";

    Connection conexion = null;
    PreparedStatement consultaSuc = null;
    PreparedStatement consultaPreparada = null;
    PreparedStatement consultaRelacion = null;
    ResultSet listaSucursal = null;

    try {
        conexion = DriverManager.getConnection("jdbc:mysql://localhost:3306/electrodelta", "root", "admin");
        consultaSuc = conexion.prepareStatement(SelectSuc);
        consultaSuc.setString(1, request.getParameter("id_sucu"));
        listaSucursal = consultaSuc.executeQuery();
        listaSucursal.next();
%>
    <head>
        <title><%out.print(listaSucursal.getString("denom"));%></title>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
    </head>

    <body>
        <h3>Ingresá la información sobre el producto para sucursal:</h3>
        <h2><%out.print(listaSucursal.getString("denom"));%></h2>

        <%
        consultaPreparada = conexion.prepareStatement(insert);
        consultaPreparada.setString(1, request.getParameter("producto"));
        consultaPreparada.setString(2, request.getParameter("descripcion"));
        consultaPreparada.setString(3, request.getParameter("precio"));
        consultaPreparada.setString(4, request.getParameter("codigo"));
        consultaRelacion = conexion.prepareStatement(insertStock);
        consultaRelacion.setString(1, request.getParameter("id_sucu"));
        consultaRelacion.setString(2, request.getParameter("codigo"));
        consultaRelacion.setString(3, request.getParameter("cantidad"));

        consultaPreparada.execute();
        consultaRelacion.execute();
        out.print("PRODUCTO CARGADO");
        out.print("<br/><br/><a href='index.jsp' class='btn btn-white btn-circled'>Volver</a>");

        } catch (Exception e) {
            e.printStackTrace();
            out.println("Hubo un problema al cargar la página.");
            out.println("Detalle de la consulta:");
            out.println(consultaPreparada + "<br/>");
            out.println(consultaRelacion + "<br/>");
        } finally {
            try {
                consultaPreparada.close();
                consultaRelacion.close();
                consultaSuc.close();
                conexion.close();
            } catch (Exception e) {
            }
        }
    %>
    </body>
</html>
