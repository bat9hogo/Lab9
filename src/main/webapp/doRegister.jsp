<%@page language="java" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@taglib prefix="ad" uri="http://tag/ad"%>
<fmt:requestEncoding value="UTF-8" />
<c:remove var="userData" />
<jsp:useBean id="userData" class="entity.User" scope="session" />
<jsp:setProperty name="userData" property="*" />

<%@ page import="java.io.*, java.net.*, java.nio.charset.StandardCharsets" %>
<%@ page import="org.json.JSONObject" %>
<%!
  public boolean verifyRecaptcha(String gRecaptchaResponse) {
    String secretKey = "6Le6p-kqAAAAADJoWovZ79OYsN-mXZ-zog1brfrl"; // Замените на свой Secret Key
    String url = "https://www.google.com/recaptcha/api/siteverify";

    try {
      String params = "secret=" + secretKey + "&response=" + gRecaptchaResponse;
      URL obj = new URL(url);
      HttpURLConnection con = (HttpURLConnection) obj.openConnection();
      con.setRequestMethod("POST");
      con.setDoOutput(true);

      OutputStreamWriter writer = new OutputStreamWriter(con.getOutputStream(), StandardCharsets.UTF_8);
      writer.write(params);
      writer.flush();
      writer.close();

      BufferedReader reader = new BufferedReader(new InputStreamReader(con.getInputStream(), StandardCharsets.UTF_8));
      StringBuilder responseStr = new StringBuilder();
      String responseLine;

      while ((responseLine = reader.readLine()) != null) {
        responseStr.append(responseLine);
      }
      reader.close();

      JSONObject json = new JSONObject(responseStr.toString());
      return json.getBoolean("success");
    } catch (Exception e) {
      e.printStackTrace();
      return false;
    }
  }
%>

<%
  String recaptchaResponse = request.getParameter("g-recaptcha-response");

  if (recaptchaResponse == null || !verifyRecaptcha(recaptchaResponse)) {
    session.setAttribute("errorMessage", "Ошибка CAPTCHA! Попробуйте снова.");
    response.sendRedirect("register.jsp");
    return;
  }
%>

<ad:addUser user="${userData}" />

<c:choose>
  <c:when test="${sessionScope.errorMessage==null}">
    <c:remove var="userData" scope="session" />
    <jsp:forward page="/doLogin.jsp" />
  </c:when>
  <c:otherwise>
    <c:redirect url="/register.jsp" />
  </c:otherwise>
</c:choose>
