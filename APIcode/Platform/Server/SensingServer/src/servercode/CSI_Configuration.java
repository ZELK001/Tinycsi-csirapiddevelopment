package servercode;

public class CSI_Configuration {
	private String CSIfilename;
	private double samplerate;
	private int duration;

	public CSI_Configuration(String csifilename, double samplerate, int duration) {
		this.CSIfilename = csifilename;
		this.samplerate = samplerate;
		this.duration = duration;
	}

	public String getcsifilename() {
		return CSIfilename;
	}

	public void setX(String csifilename) {
		this.CSIfilename = csifilename;
	}

	public double getsamplerate() {
		return samplerate;
	}

	public void setY(double samplerate) {
		this.samplerate = samplerate;
	}

	public int getduration() {
		return duration;
	}

	public void setY(int duration) {
		this.duration = duration;
	}

}