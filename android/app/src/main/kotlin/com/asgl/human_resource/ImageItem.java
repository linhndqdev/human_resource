package com.asgl.human_resource;

/**
 * Holds image details, this class is used as queue item
 *
 * @author Jan Peter Hooiveld
 */
public class ImageItem {
    /**
     * Image id
     */
    public String imageId;

    /**
     * Location where image is stored
     */
    public String imagePath;

    /**
     * Filename of the image
     */
    public String imageName;

    /**
     * Image mime-type
     */
    public String imageType;

    /**
     * Image size
     */
    public int imageSize;

    public ImageItem(String imageId, String imagePath, String imageName, String imageType, int imageSize) {
        this.imageId = imageId;
        this.imagePath = imagePath;
        this.imageName = imageName;
        this.imageType = imageType;
        this.imageSize = imageSize;
    }
}
