/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package mcvc.servlets;

import java.io.IOException;
import java.io.PrintWriter;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import mcvc.util.Sqlquery;

/**
 *
 * @author camilo
 */
@WebServlet(name = "RegistrarServlets", urlPatterns = {"/RegistrarServlets"})
public class RegistrarServlets extends HttpServlet {

    /**
     * Processes requests for both HTTP
     * <code>GET</code> and
     * <code>POST</code> methods.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();
        Sqlquery sqlquery = new Sqlquery();
            sqlquery.setcurrentSession();
        try {
            String email = request.getParameter("email");
            String nombre = request.getParameter("nombre");
            String apellido1 = request.getParameter("1apellido");
            String apellido2 = request.getParameter("2apellido");
            String celular = request.getParameter("celular");
            String telefono = request.getParameter("telefono");
            String cont = request.getParameter("pass");
            String contraseña = StringMD.getStringMessageDigest(cont, "MD5");

            if( cont.length() < 6)
            {
                 response.sendRedirect("MsjError.jsp?msj=Contraseña debe contener al menos 6 caracteres"+ "&topage=Registrar&text=Registrar");
            }
            
            String mes = sqlquery.insertUser(email, nombre, apellido1, apellido2, celular, telefono, contraseña);
           
            
            if (!mes.equals("")) {
                response.sendRedirect("MsjError.jsp?msj=" + mes + "&topage=Registrar&text=Registrar");
            } else {
                response.sendRedirect("index.jsp");
            }
        } finally {
             sqlquery.closeSession();
            out.close();
        }
    }

    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /**
     * Handles the HTTP
     * <code>GET</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    /**
     * Handles the HTTP
     * <code>POST</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    /**
     * Returns a short description of the servlet.
     *
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>
}
