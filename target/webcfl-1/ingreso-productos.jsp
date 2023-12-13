<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.io.*"%>
<%@ page import="java.util.*"%>

<%
    String nombreSucursal = request.getParameter("sucursal");
    if (nombreSucursal == null || nombreSucursal.isEmpty()) {
        out.println("Error: El parámetro 'sucursal' no está presente en la URL.");
        return;
    }

    Connection conexion = null;
    PreparedStatement consultaSucursal = null;
    ResultSet resultadoSucursal = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conexion = DriverManager.getConnection("jdbc:mysql://localhost:3306/electrodelta", "root", "admin");

        String sucursalQuery = "SELECT suc_id FROM sucs_tb WHERE denom = ?";
        consultaSucursal = conexion.prepareStatement(sucursalQuery);
        consultaSucursal.setString(1, nombreSucursal);

        resultadoSucursal = consultaSucursal.executeQuery();

        if (resultadoSucursal.next()) {
            String sucursalId = resultadoSucursal.getString("suc_id");

            // Obtener los datos del formulario
            String producto = request.getParameter("producto");
            String descripcion = request.getParameter("descripcion");
            String codigo = request.getParameter("codigo");
            String cantidadStr = request.getParameter("cantidad");
            String precioStr = request.getParameter("precio");

            // Verificar si el producto ya existe en la sucursal
            String productoQuery = "SELECT stock FROM prod_suc WHERE sucu_id = ? AND produc_id = ?";
            PreparedStatement consultaProducto = conexion.prepareStatement(productoQuery);
            consultaProducto.setString(1, sucursalId);
            consultaProducto.setString(2, codigo);

            ResultSet resultadoProducto = consultaProducto.executeQuery();

            if (resultadoProducto.next()) {
                // El producto ya existe, actualizar la cantidad
                int cantidadActual = resultadoProducto.getInt("stock");
                int cantidadNueva = Integer.parseInt(cantidadStr);
                int nuevaCantidadTotal = cantidadActual + cantidadNueva;

                String actualizarProductoQuery = "UPDATE prod_suc SET stock = ? WHERE sucu_id = ? AND produc_id = ?";
                PreparedStatement actualizarProducto = conexion.prepareStatement(actualizarProductoQuery);
                actualizarProducto.setInt(1, nuevaCantidadTotal);
                actualizarProducto.setString(2, sucursalId);
                actualizarProducto.setString(3, codigo);

                actualizarProducto.executeUpdate();
            } else {
                // El producto no existe, insertarlo
                int cantidadNueva = Integer.parseInt(cantidadStr);
                int precio = Integer.parseInt(precioStr);

                // Verificar si el producto ya existe en la tabla prod_tb
                String productoTablaQuery = "SELECT * FROM prod_tb WHERE cod = ?";
                PreparedStatement consultaProductoTabla = conexion.prepareStatement(productoTablaQuery);
                consultaProductoTabla.setString(1, codigo);

                ResultSet resultadoProductoTabla = consultaProductoTabla.executeQuery();

                if (resultadoProductoTabla.next()) {
                    // El producto ya existe en la tabla prod_tb, verificar y actualizar el precio si es necesario
                    int precioTabla = resultadoProductoTabla.getInt("precio");
                    if (precio != precioTabla) {
                        String actualizarPrecioQuery = "UPDATE prod_tb SET precio = ? WHERE cod = ?";
                        PreparedStatement actualizarPrecio = conexion.prepareStatement(actualizarPrecioQuery);
                        actualizarPrecio.setInt(1, precio);
                        actualizarPrecio.setString(2, codigo);

                        actualizarPrecio.executeUpdate();
                    }
                } else {
                    // El producto no existe en la tabla prod_tb, insertarlo
                    String insertarProductoQuery = "INSERT INTO prod_suc (sucu_id, produc_id, stock) VALUES (?, ?, ?)";
                    PreparedStatement insertarProducto = conexion.prepareStatement(insertarProductoQuery);
                    insertarProducto.setString(1, sucursalId);
                    insertarProducto.setString(2, codigo);
                    insertarProducto.setInt(3, cantidadNueva);

                    insertarProducto.executeUpdate();
                }
            }

        } else {
            out.println("No se encontró la sucursal.");
        }
    } catch (ClassNotFoundException | SQLException e) {
        e.printStackTrace();
        out.println("Hubo un problema al recuperar la sucursal.");
    } finally {
        // Cierre de recursos
        try {
            if (conexion != null) {
                conexion.close();
            }
            if (consultaSucursal != null) {
                consultaSucursal.close();
            }
            if (resultadoSucursal != null) {
                resultadoSucursal.close();
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
    }
%>
