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
 * @author mairen
 */
@WebServlet(name = "RegistrarToken_Servlet", urlPatterns = {"/RegistrarToken_Servlet"})
public class RegistrarToken_Servlet extends HttpServlet {

    /** 
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code> methods.
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();
        Sqlquery sql = new Sqlquery();
            sql.setcurrentSession();
        try {
            String token=request.getParameter("txt_token");
            
            Integer id=sql.getiD(token);
            if(id!=null){
            sql.registrarToken(id,(String) request.getSession().getAttribute("usuario"));
            
            response.sendRedirect("Home.jsp");
            }else{
            response.sendRedirect("MsjError.jsp?msj=EL TOKEN NO EXISTE&topage=Home&text=Home");
            }

        } finally {   
            sql.closeSession();
            out.close();
        }
    }

    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /** 
     * Handles the HTTP <code>GET</code> method.
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
     * Handles the HTTP <code>POST</code> method.
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
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>
}
