package servercode;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.io.PrintWriter;
import java.net.Socket;

/*
 * 功能：服务器处理用户请求及发送控制信号
 */
class ServerThreadCode extends Thread {
	private Socket clientSocket = null;// 客户套接字
	private BufferedReader sin = null;// 负责包装套接字输入流
	private PrintWriter sout = null;// 负责包装套接字输出流

	String Username = null;// 用户名
	String DeviceID = null;// 设备名
	private boolean isDevice = false;
	ControlWindow cw = null;

	public ServerThreadCode(Socket s, CSI_Configuration csiconfig) throws IOException {

		this.clientSocket = s;

		try {
			sin = new BufferedReader(new InputStreamReader(clientSocket.getInputStream()));
			sout = new PrintWriter(new BufferedWriter(new OutputStreamWriter(clientSocket.getOutputStream())), true);
			start();// 启动线程
		} catch (Exception e) {
		}
	}

	public void run() {

		for (;;)// 一直接受安卓端信息
		{
			try {
				String str = sin.readLine();// 读数据
				System.out.println("缓冲区数据：" + str + "\n");
				if (str == null) {
					// 写入日志，动作：退出控制
					System.out.println(Username + "(安卓端)关闭套接字,退出控制" + "\n");
					cw.setVisible(false);
					break;
				}
				// 设备登录
				if (str.startsWith("<LOGIN>")) {
					System.out.println("请求指令为：<LOGIN>\n");
					String msg = str.substring(7);// 获取包含用户名，用户密码的字符串
					String[] order = msg.split("\\|");// 用“|”分割
					Username = order[0];// 获得用户名

					System.out.println("用户： " + Username + "上线\n");

					sout.println("ok");
					sout.flush();
					// 进入控制窗口,这里新起线程才可以与安卓端跳转之后的页面activity(Android_Control)和service进行通信
					new Thread() {
						@Override
						public void run() {
							try {
								cw = new ControlWindow(Username, clientSocket);
								cw.setVisible(true);
							} catch (IOException e) {
								// TODO Auto-generated catch block
								e.printStackTrace();
							}
						}// Thread run()
					}.start();

				} // if(<LOGIN>)
				else if (str.startsWith("<HeartBeatTest>")) {

					// showArea.append("心跳包检测连接是否正常\n");

				}

				else {
					// 动作：退出控制
					System.out.println("用户： " + Username + "退出\n");
				}

			} catch (IOException e) {
				// 通过使用心跳包机制检测客户端网络连接是否正常
				// 服务器端接收超时时间为5s，客户端每隔1s发送一个心跳包，不会影响正常通信
				System.out.println(Username + " 客户端网络断开，结束线程\n");

				System.out.println(Username + "连接终止" + "\n");

				cw.setVisible(false);

				break;
			}

		} // for
	}
}
