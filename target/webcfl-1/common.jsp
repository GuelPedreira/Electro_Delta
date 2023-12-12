<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.DriverManager"%>
<%@page import="java.sql.Connection"%>

<%
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        String url = "jdbc:mysql://localhost:3306/electrodelta";
        String user = "root";
        String password = "admin";

        try (Connection conexion = DriverManager.getConnection(url, user, password)) {
            pageContext.getServletContext().log("Conexión a la base de datos establecida correctamente.");

            // Obtener información de la sucursal si es necesario
            String selectSuc = "SELECT denom FROM sucs_tb WHERE suc_id = ?";
            try (PreparedStatement consultaSuc = conexion.prepareStatement(selectSuc)) {
                consultaSuc.setString(1, request.getParameter("id"));
                try (ResultSet listaSucursal = consultaSuc.executeQuery()) {
                    // Puedes usar listaSucursal para obtener información específica de la sucursal si es necesario
                }
            } catch (Exception e) {
                pageContext.getServletContext().log("Error al obtener información de la sucursal.", e);
            }

        } catch (Exception e) {
            pageContext.getServletContext().log("Error al cerrar la conexión a la base de datos.", e);
        }

    } catch (ClassNotFoundException e) {
        pageContext.getServletContext().log("Error al cargar el controlador de la base de datos.", e);
    } catch (Exception e) {
        pageContext.getServletContext().log("Hubo un problema al conectar a la base de datos.", e);
    }
%>
