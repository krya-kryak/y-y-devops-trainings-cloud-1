package main

import (
	"bytes"
	"context"
	_ "embed"
	"fmt"
	"image"
	"image/draw"
	"image/jpeg"
	"image/png"
	"io"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/service/s3"
)

type catGPT struct {
	client *s3.Client
	bucket string
}

func (c *catGPT) List(ctx context.Context) ([]string, error) {
	result, err := c.client.ListObjectsV2(ctx, &s3.ListObjectsV2Input{
		Bucket: aws.String(c.bucket),
	})
	if err != nil {
		return nil, err
	}
	var res []string
	for _, object := range result.Contents {
		res = append(res, aws.ToString(object.Key))
	}
	return res, nil
}

func (c *catGPT) Put(ctx context.Context, key string, data io.Reader) error {
	_, err := c.client.PutObject(ctx, &s3.PutObjectInput{
		Bucket: &c.bucket,
		Key:    &key,
		Body:   data,
	})
	return err
}

func (c *catGPT) Get(ctx context.Context, key string) (io.ReadCloser, error) {
	output, err := c.client.GetObject(ctx, &s3.GetObjectInput{
		Bucket: &c.bucket,
		Key:    &key,
	})
	if err != nil {
		return nil, err
	}
	return output.Body, nil
}

func (c *catGPT) EnsureIsImage(r io.Reader) (image.Image, error) {
	photo, _, err := image.Decode(r)
	if err != nil {
		return nil, err
	}
	b := photo.Bounds()
	if b.Max.X < 600 || b.Max.Y < 600 {
		return nil, fmt.Errorf("resolutions below 600x600 are not allowed, got %dx%d", b.Max.X, b.Max.Y)
	}
	return photo, nil
}

var (
	//go:embed watermark.png
	dayCatBytes []byte
	//go:embed watermark_night.png
	nightCatBytes []byte
)

func (c *catGPT) Enhance(photo image.Image, catType Cat) (io.Reader, error) {
	var catBytes = dayCatBytes
	if catType == CatNocturnal {
		catBytes = nightCatBytes
	}
	// Errors like this should not be ignored in real life.
	cat, _ := png.Decode(bytes.NewReader(catBytes))
	pb := photo.Bounds()
	cb := cat.Bounds()
	offset := image.Pt(pb.Max.X-cb.Max.X, pb.Max.Y-cb.Max.Y)

	res := image.NewRGBA(pb)
	draw.Draw(res, pb, photo, image.Point{}, draw.Src)
	draw.Draw(res, cb.Add(offset), cat, image.Point{}, draw.Over)

	var buf bytes.Buffer
	err := jpeg.Encode(&buf, res, &jpeg.Options{Quality: jpeg.DefaultQuality})
	if err != nil {
		return nil, err
	}
	return &buf, nil
}
