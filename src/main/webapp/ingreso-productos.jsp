<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.io.*"%>
<%@ page import="java.util.*"%>

<%
    String nombreSucursal = request.getParameter("sucursal");
    String producto = request.getParameter("producto").toUpperCase();
    String descripcion = request.getParameter("descripcion").toUpperCase();
    String codigo = request.getParameter("codigo").toUpperCase();
    int cantidad = Integer.parseInt(request.getParameter("cantidad"));
    int precio = Integer.parseInt(request.getParameter("precio"));

    Connection conexion = null;
    PreparedStatement consultaProducto = null;
    PreparedStatement consultaStock = null;
    PreparedStatement insertProducto = null;
    PreparedStatement updateStock = null;
    ResultSet resultadoProducto = null;
    ResultSet resultadoStock = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conexion = DriverManager.getConnection("jdbc:mysql://localhost:3306/electrodelta", "root", "admin");

        // Verificar si el producto ya existe en la tabla prod_tb
        String productoQuery = "SELECT prod_id, precio FROM prod_tb WHERE cod = ?";
        consultaProducto = conexion.prepareStatement(productoQuery);
        consultaProducto.setString(1, codigo);
        resultadoProducto = consultaProducto.executeQuery();

        if (resultadoProducto.next()) {
            int productoId = resultadoProducto.getInt("prod_id");
            int precioExistente = resultadoProducto.getInt("precio");

            // Verificar si el producto ya existe en la tabla prod_suc para la sucursal especificada
            if (nombreSucursal != null && !nombreSucursal.isEmpty()) {
                String stockQuery = "SELECT stock FROM prod_suc WHERE sucu_id = ? AND produc_id = ?";
                consultaStock = conexion.prepareStatement(stockQuery);
                consultaStock.setString(1, nombreSucursal);
                consultaStock.setInt(2, productoId);
                resultadoStock = consultaStock.executeQuery();

                if (resultadoStock.next()) {
                    int stockExistente = resultadoStock.getInt("stock");

                    // Actualizar el stock existente sumando la cantidad ingresada
                    int nuevoStock = stockExistente + cantidad;
                    String updateStockQuery = "UPDATE prod_suc SET stock = ? WHERE sucu_id = ? AND produc_id = ?";
                    updateStock = conexion.prepareStatement(updateStockQuery);
                    updateStock.setInt(1, nuevoStock);
                    updateStock.setString(2, nombreSucursal);
                    updateStock.setInt(3, productoId);
                    updateStock.executeUpdate();
                } else {
                    // Insertar el producto en la tabla prod_suc con el stock ingresado
                    String insertStockQuery = "INSERT INTO prod_suc (sucu_id, produc_id, stock) VALUES (?, ?, ?)";
                    insertProducto = conexion.prepareStatement(insertStockQuery);
                    insertProducto.setString(1, nombreSucursal);
                    insertProducto.setInt(2, productoId);
                    insertProducto.setInt(3, cantidad);
                    insertProducto.executeUpdate();
                }

                // Verificar si el precio es distinto al existente en la tabla prod_tb
                if (precio != precioExistente) {
                    String updatePrecioQuery = "UPDATE prod_tb SET precio = ? WHERE prod_id = ?";
                    PreparedStatement updatePrecio = conexion.prepareStatement(updatePrecioQuery);
                    updatePrecio.setInt(1, precio);
                    updatePrecio.setInt(2, productoId);
                    updatePrecio.executeUpdate();
                }
            } else {
                out.println("El nombre de la sucursal no puede ser nulo o vacío.");
            }
        } else {
            // Insertar el producto en la tabla prod_tb y en la tabla prod_suc con el stock ingresado
            String insertProductoQuery = "INSERT INTO prod_tb (nom_prod, descrip, cod, precio) VALUES (?, ?, ?, ?)";
            insertProducto = conexion.prepareStatement(insertProductoQuery, Statement.RETURN_GENERATED_KEYS);
            insertProducto.setString(1, producto);
            insertProducto.setString(2, descripcion);
            insertProducto.setString(3, codigo);
            insertProducto.setInt(4, precio);
            insertProducto.executeUpdate();

            ResultSet generatedKeys = insertProducto.getGeneratedKeys();
            if (generatedKeys.next()) {
                int productoId = generatedKeys.getInt(1);

                String insertStockQuery = "INSERT INTO prod_suc (sucu_id, produc_id, stock) VALUES (?, ?, ?)";
                PreparedStatement insertStock = conexion.prepareStatement(insertStockQuery);
                insertStock.setString(1, nombreSucursal);
                insertStock.setInt(2, productoId);
                insertStock.setInt(3, cantidad);
                insertStock.executeUpdate();
            }
        }
        
        String insertStockQuery = "INSERT INTO prod_suc (sucu_id, produc_id, stock) VALUES (?, ?, ?)";
        int productoId = 0; // Declarar la variable productoId con un valor inicial

        try {
            // Realizar la inserción en la tabla prod_suc
            PreparedStatement insertStock = conexion.prepareStatement(insertStockQuery);
            insertStock.setString(1, nombreSucursal);
            insertStock.setInt(2, productoId);
            insertStock.setInt(3, cantidad);
            insertStock.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
            out.println("Hubo un problema al insertar en la tabla prod_suc: " + e.getMessage());
        }

        // Redireccionar a la página de éxito
        response.sendRedirect("exito.jsp");
    } catch (ClassNotFoundException | SQLException e) {
        e.printStackTrace();
        out.println("Hubo un problema al procesar la solicitud: " + e.getMessage());
    } finally {
        // Cierre de recursos
        try {
            if (conexion != null) {
                conexion.close();
            }
            if (consultaProducto != null) {
                consultaProducto.close();
            }
            if (consultaStock != null) {
                consultaStock.close();
            }
            if (insertProducto != null) {
                insertProducto.close();
            }
            if (updateStock != null) {
                updateStock.close();
            }
            if (resultadoProducto != null) {
                resultadoProducto.close();
            }
            if (resultadoStock != null) {
                resultadoStock.close();
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
    }
%>
