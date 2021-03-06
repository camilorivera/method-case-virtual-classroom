<%-- 
    Document   : Participacion
    Created on : 05-20-2012, 02:42:23 PM
    Author     : Camilo-Rivera
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="mcvc.hibernate.clases.TblEstudiantesxclase"%>
<%@page import="mcvc.util.Sqlquery"%>
<%@page import="java.util.List" %>
<%Sqlquery face = new Sqlquery();%>
<%face.setcurrentSession();%>
<%Integer cls_id = face.getiD(request.getParameter("token"));    %>
<%List<TblEstudiantesxclase> lista = face.getTablaNotas(cls_id); %>

<% 
%>

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <link rel="shortcut icon" href="http://www.unitec.edu/wp-content/themes/unitec/unitec.ico" type="image/x-icon">
        <%if (session.getAttribute("usuario") == null) {
                response.sendRedirect("index.jsp");
            }%>
        <link rel="stylesheet" type="text/css" href="CSS/home.css">
        <title>MCVC</title>
    </head>
    <body>        
        <div class="box home">
            <fieldset class="boxBody">
               
                <table style="margin: 0 auto" width="100%">
                    <tr>
                        <th style="border:#000 solid 1px; margin: 0 auto "> Nombre              </th>
                        <th style="border:#000 solid 1px; margin: 0 auto"> Nota                </th>
                        <th style="border:#000 solid 1px; margin: 0 auto"> Participaciones     </th>
                    </tr>                       
                <% for(int i=0; i<lista.size(); i++)
                    {  %>    
                    <tr>
                        <td style="border:#000 solid 1px; margin: 0 auto"> 
                            <%=lista.get(i).getTblUsuarios().getUsrNombres() + " " + lista.get(i).getTblUsuarios().getUsrPrimerApellido() %>
                        </td>
                        
                        <td style="border:#000 solid 1px; margin: 0 auto">
                            <%=lista.get(i).getExcNota()%> 
                        </td>
                        
                        <td style="border:#000 solid 1px; margin: 0 auto">
                            <%=lista.get(i).getExcCantParticipaciones()%>
                        </td>
                    </tr>
                <%  }%>    
                </table>
                <br/><br/><br/><br/>
                <br/><br/><br/><br/>
                <br/><br/><br/><br/>
                <br/><br/><br/><br/>
                <br/><br/>
                
            </fieldset> 
            <footer>
                <a href="excel.jsp?token=<%=request.getParameter("token")%>" class="btnLogin" style="color: #000">Exportar Excel</a>
                <a href="Home.jsp" class="btnLogin" style="color: #000">Ir a Home</a>
            </footer>
</html>
