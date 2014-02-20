<%@ page contentType="text/html; charset=UTF-8"%>

<%@ page import="com.exedosoft.plat.bo.DOApplication"%>
<%@ page import="com.exedosoft.plat.bo.DODataSource"%>
<%@ page import="com.exedosoft.plat.bo.BOInstance"%>
<%@ page import="com.exedosoft.plat.DAOUtil"%>
<%@ page import="com.exedosoft.plat.util.DOGlobals"%>
<%@ page import="com.exedosoft.plat.util.I18n"%>
<%@ page import="java.util.List"%>
<%@ page import="java.util.Iterator"%>
<%@ page import="com.exedosoft.plat.bo.DOResource"%>
<%
	response.setHeader("Pragma", "No-cache");
	response.setHeader("Cache-Control", "no-cache");
	response.setDateHeader("Expires", 0);
%>
<%	
	String userName = "";
	String default_app_uid = "";  
	String company = "";
	SessionContext exedoContext = (SessionContext) session
			.getAttribute("userInfo");
	boolean isDev = false;
	if (exedoContext != null && exedoContext.getUser() != null) {
		
		System.out.println("exedoContext.getUser():::" + exedoContext.getUser());
		userName = exedoContext.getUser().getName();
		default_app_uid = exedoContext.getUser().getValue("default_app_uid");
		if("1".equals(exedoContext.getUser().getValue("asrole")) || "2".equals(exedoContext.getUser().getValue("asrole"))){
			isDev = true;
		}
		company =  exedoContext.getUser().getValue("company");
		if(company == null || "".equals(company)){
			company = I18n.instance().get("普通用户");
		}
	}

	BOInstance delegate = SessionContext.getInstance().getDeleGate();
	if(delegate!=null && delegate.getName()!=null){
		userName = userName + "（" + I18n.instance().get("代理") + delegate.getName() + "）";
	}
	
	if(DOGlobals.getInstance().getSessoinContext()==null || DOGlobals.getInstance().getSessoinContext().getTenancyValues()==null){
		response.getWriter().write("<script>window.location='web/default/logoff.jsp'; </script>");
		return;
	}
	
	DODataSource dds = DOGlobals.getInstance().getSessoinContext().getTenancyValues().getDds();
	List apps =  DAOUtil.INSTANCE().currentDataSource(dds).select(DOApplication.class,
			"select * from DO_Application  order by session_overDue  desc");

  	String url = 	DOResource.getSpecialPath(DOResource.TYPE_LOGO_SMALL);
  	if(url==null){
	 	 url = request.getContextPath() + "/web/default/images/logo_small_l.png";
 	 }
%>

  .welcome {
	   color:#3C3C3C;
	   left:188px;
	   position:absolute;
	   top:17px;
  }
  .inner {
	   color:#3C3C3C;
  }
  .control{
  	color:#929393;
  	text-decoration:none;
  	position:absolute;
  	right:10px;
  	top:15px;
  	cursor:pointer;
  	line-height:167%;
  }
  .selectt{
  	width:134px;
  	display:inline;
  	color:black;
    font-weight:bold;
  }



  function logOff(){
	  if(confirm('<%=I18n.instance().get("Confirm Exit")%>')){
	  	window.location.href="web/default/logoff.jsp";
	  }
  }

  function helpme(){
   		window.open('http://code.google.com/p/eeplat');
  }

  function setup(){
		window.open("console.pml?isApp=true");
  }

  function changeApp(obj){
	  
	  if(obj!=null && obj.value!=null && obj.value!='f' && obj.value!='a'){
		  var datas = obj.value.split(";");
			var url = globalURL + "/servicecontroller?dataBus=setUserContext&contextKey=default_app_uid&contextValue=" +datas[0];
			$.get(url,function(data){window.location = datas[1];});
	  }else if(obj!=null && obj.value=='a'){
		  loadPml({'pml':'appshare','target':'_opener_tab','title':'<%=I18n.instance().get("从AppShare安装")%>'});
      }
  }

<div>
	<div algin="left" id='logoPic' style='z-index:1; height: 0; left: 0px; position: absolute; top: 1px; width: 0;'><img name='logoImg'  height="40px"  src='<%=url%>' border='0'></div>
	
	 <div class="control">
	    <span class="inner">
			<%=I18n.instance().get("Welcome")%>，<%=userName%> ！
		</span>[ <%=company%> ]
		&nbsp;&nbsp;
		<select class="selectt" onchange="changeApp(this)">
		   <%for(Iterator it  = apps.iterator(); it.hasNext();) { DOApplication doa = (DOApplication)it.next(); 
			   if(!isDev  && doa.getName().equals("SystemManager")){
				   continue;				   
			   }
		   %>
		   <option value="<%=doa.getObjUid()%>;<%=doa.getOuterLinkPaneStr()%>" <% if(doa.getObjUid().equals(default_app_uid)) { %>selected<%}%>><%=doa.getL10n()%></option>
			<%} %>
			
			<%if(isDev){ %>
		    <option value="f">--------------</option>
		    <option value="a"><%=I18n.instance().get("从AppShare安装")%></option>
		    <% }%>
		   </select>
		&nbsp;&nbsp;
		
		<%if(isDev){ %><a onclick="setup()" ><%=I18n.instance().get("Setup")%> </a> | <%} %> <a onclick="helpme();" ><%=I18n.instance().get("Help")%></a>  | <a onclick="logOff()" ><%=I18n.instance().get("Logout")%></a>
	</div>


