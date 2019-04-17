package servercode;

import java.net.InetAddress;
import java.net.ServerSocket;
import java.net.Socket;

/*
 * 功能：服务器主界面，负责显示日志和客户端与服务器端之间的交互信息
 */
public class ServerMain {

	private CSI_Configuration csiconfig;

	public ServerMain() throws Exception {

		// int port = 8099;// 服务器服务端口号
		//
		// ServerSocket s;
		// s = new ServerSocket(port);
		// // 显示服务器本地IP地址
		// System.out.println("服务器端地址：" + InetAddress.getLocalHost().getHostAddress() +
		// "\n");
		// System.out.println("Server's Services Start.......");
		// System.out.println("Serve socket is" + s.toString());
		// // 服务器端多线程服务
		// try {
		// while (true) {
		// Socket incoming = s.accept();
		// // 打印连接的客户端套接字信息
		// System.out.println(incoming.getInetAddress() + ":" + incoming.getPort() +
		// "终端连接成功，等待登录。。。。。" + "\n");
		// // 对每一个连接的用户启动服务线程
		// new ServerThreadCode(incoming, csiconfig);
		// }
		// } catch (Exception e1) {
		// // TODO Auto-generated catch block
		// e1.printStackTrace();
		// }
	}

	public void createServer(String csifilename, double samplerate, int duration) {
		csiconfig = new CSI_Configuration(csifilename, samplerate, duration);
		System.out.println("新服务器端");
		System.out.println(csifilename + " " + samplerate + " " + duration);
		new Thread() {
			@Override
			public void run() {
				try {

					int port = 8099;// 服务器服务端口号
					ServerSocket s;
					s = new ServerSocket(port);
					// 显示服务器本地IP地址
					System.out.println("服务器端地址：" + InetAddress.getLocalHost().getHostAddress() + "\n");
					System.out.println("Server's Services Start.......");
					System.out.println("Serve socket is " + s.toString());
					// 服务器端多线程服务

					while (true) {
						System.out.println("在while里了");
						Socket incoming = s.accept();
						// 打印连接的客户端套接字信息
						System.out.println(
								incoming.getInetAddress() + ":" + incoming.getPort() + "终端连接成功，等待登录。。。。。" + "\n");
						// 对每一个连接的用户启动服务线程
						new ServerThreadCode(incoming, csiconfig);
					}

				} catch (Exception e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
			}// Thread run()
		}.start();
	}

	public static void main(String[] args) throws Exception {

		// new Thread() {
		// @Override
		// public void run() {
		// try {
		// new ServerMain("111", 0.01, 100);
		// } catch (Exception e) {
		// // TODO Auto-generated catch block
		// e.printStackTrace();
		// }
		// }// Thread run()
		// }.start();
		// new ServerMain("111", 0.01, 111);
		// int port = 8099;// 服务器服务端口号
		// new ServerMain();
		// ServerSocket s;
		// s = new ServerSocket(port);
		// // 显示服务器本地IP地址
		// System.out.println("服务器端地址：" + InetAddress.getLocalHost().getHostAddress() +
		// "\n");
		// System.out.println("Server's Services Start.......");
		// System.out.println("Serve socket is" + s.toString());
		// // 服务器端多线程服务
		// try {
		// while (true) {
		// Socket incoming = s.accept();
		// // 打印连接的客户端套接字信息
		// System.out.println(incoming.getInetAddress() + ":" + incoming.getPort() +
		// "终端连接成功，等待登录。。。。。" + "\n");
		// // 对每一个连接的用户启动服务线程
		// new ServerThreadCode(incoming);
		// }
		// } catch (Exception e1) {
		// // TODO Auto-generated catch block
		// e1.printStackTrace();
		// }

	}

}
