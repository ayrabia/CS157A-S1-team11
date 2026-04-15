<%@ page session="true" %>
<%
    session.invalidate();
    response.sendRedirect("index.html");
%>
