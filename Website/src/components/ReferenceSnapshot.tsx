type Props = {
	alt: string;
	caption: string;
	height: number;
	src: string;
	width: number;
};

export default function ReferenceSnapshot({
	alt,
	caption,
	height,
	src,
	width,
}: Props) {
	return (
		<figure className="r95-component-preview">
			<img src={src} width={width} height={height} alt={alt} />
			<figcaption>{caption}</figcaption>
		</figure>
	);
}
