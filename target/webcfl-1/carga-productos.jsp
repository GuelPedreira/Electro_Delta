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

        String sucursalQuery = "SELECT suc_id, domic FROM sucs_tb WHERE denom = ?";
        consultaSucursal = conexion.prepareStatement(sucursalQuery);
        consultaSucursal.setString(1, nombreSucursal);

        resultadoSucursal = consultaSucursal.executeQuery();

        if (resultadoSucursal.next()) {
            String sucursalId = resultadoSucursal.getString("suc_id");
            String domicilio = resultadoSucursal.getString("domic");
%>

<!DOCTYPE html>
<html lang="es">

<head>
    <title>Sucursal - <%= nombreSucursal %></title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" type="text/css" href="css/style.css">
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Poppins:400,600,700|Rubik:400,600,700">

    <style>
        body {
            margin: 0;
            padding: 0;
        }

        .banner {
            background-image: url('img/cambiar-electrodomesticos.jpg');
            color: #B0B0B0;
            padding: 20px 20px; /* Ajusta el tamaño de la banda superior */
            text-align: center;
            font-weight: 600;
            font-size: 20px;
        }

        .content {
            background-color: #14a44d;
            padding: 15px;
            border-radius: 10px;
            width: 40%;
            margin: auto;
            text-align: center;
            position: relative;
            z-index: 1;
        }

        .btn-ingresar {
            background-color: #0c622e;
            color: #fff;
        }

        .btn-cancelar {
            background-color: #dc3545;
            color: #fff;
        }

        #volver {
            margin-top: 20px;
            display: block;
            width: 150px;
            margin: auto;
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

<body style="background-image: url('img/cambiar-electrodomesticos.jpg')">

    <!-- Banner -->
    <div class="banner">
        <div>SUCURSAL: <%= nombreSucursal %></div>
        <div>DOMICILIO: <%= domicilio %></div>
    </div>

    <!-- Formulario de ingreso de productos -->
    <div class="content">
        <div style="font-size: 24px; font-weight: 600; margin-bottom: 20px;">INGRESAR PRODUCTOS</div>
        <form action="ingreso-productos.jsp" method="post">
            <div class="form-group">
                <label for="producto">PRODUCTO:</label>
                <input type="text" class="form-control" id="producto" name="producto" required oninput="centrarTexto(this)">
            </div>
            <div class="form-group">
                <label for="descripcion">DESCRIPCIÓN:</label>
                <input type="text" class="form-control" id="descripcion" name="descripcion" required oninput="centrarTexto(this)">
            </div>
            <div class="form-group">
                <label for="codigo">CÓDIGO:</label>
                <input type="text" class="form-control" id="codigo" name="codigo" required oninput="centrarTexto(this)">
            </div>
            <div class="form-group">
                <label for="cantidad">CANTIDAD:</label>
                <input type="text" class="form-control" id="cantidad" name="cantidad" required oninput="centrarTexto(this)">
            </div>
            <div class="form-group">
                <label for="precio">PRECIO:</label>
                <input type="text" class="form-control" id="precio" name="precio" required oninput="centrarTexto(this)">
            </div>
            <button type="submit" class="btn btn-ingresar">INGRESAR</button>
            <button type="button" class="btn btn-cancelar" onclick="limpiarFormulario()">CANCELAR</button>
        </form>
    </div>

    <!-- Botón de volver -->
    <a href="index.jsp" class="volver">Volver</a>
</div>


    <!-- Scripts de Bootstrap (asegúrate de tener Internet para cargar estos recursos) -->
    <script src="https://code.jquery.com/jquery-3.3.1.slim.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.7/umd/popper.min.js"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/js/bootstrap.min.js"></script>

    <script>
        function centrarTexto(element) {
            element.style.textAlign = 'center';
        }

        function limpiarFormulario() {
            document.getElementById("producto").value = "";
            document.getElementById("descripcion").value = "";
            document.getElementById("codigo").value = "";
            document.getElementById("cantidad").value = "";
            document.getElementById("precio").value = "";
        }
    </script>

</body>

</html>
<%
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
