<%@ page import="java.sql.Connection"%>
<%@ page import="java.sql.PreparedStatement"%>
<%@ page import="java.sql.DriverManager"%>
<%@ page import="java.sql.SQLException"%>

<%
String nombreSucursal = request.getParameter("sucursal");
String productoCodigo = request.getParameter("productoCodigo");

if (nombreSucursal == null || nombreSucursal.isEmpty() || productoCodigo == null || productoCodigo.isEmpty()) {
    // Manejo de error: Parámetros faltantes o inválidos
    out.println("Error: Parámetros faltantes o inválidos.");
    return;
}

Connection conexion = null;
PreparedStatement eliminarProducto = null;

try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    conexion = DriverManager.getConnection("jdbc:mysql://localhost:3306/electrodelta", "root", "admin");

    // Preparar la consulta para eliminar el producto de la sucursal
    String eliminarProductoQuery = "DELETE FROM prod_suc WHERE sucu_id = (SELECT suc_id FROM sucs_tb WHERE denom = ?) AND produc_id = (SELECT prod_id FROM prod_tb WHERE cod = ?)";
    eliminarProducto = conexion.prepareStatement(eliminarProductoQuery);
    eliminarProducto.setString(1, nombreSucursal);
    eliminarProducto.setString(2, productoCodigo);

    // Ejecutar la consulta para eliminar el producto
    int filasAfectadas = eliminarProducto.executeUpdate();

    // Verificar si se eliminó correctamente
    if (filasAfectadas > 0) {
        out.println("Producto eliminado correctamente.");
    } else {
        out.println("No se pudo eliminar el producto.");
    }

} catch (ClassNotFoundException | SQLException e) {
    e.printStackTrace();
    out.println("Hubo un problema al eliminar el producto.");
} finally {
    // Cierre de recursos
    try {
        if (conexion != null) {
            conexion.close();
        }
        if (eliminarProducto != null) {
            eliminarProducto.close();
        }
    } catch (SQLException ex) {
        ex.printStackTrace();
    }
}

// Redireccionar de nuevo a la página original (baja-productos.jsp)
response.sendRedirect("baja-productos.jsp?sucursal=" + nombreSucursal);
%>
