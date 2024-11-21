export class NotificationEvent {
    public title: string;
    public body: string;
    public data: Record<string, string>;

    constructor(title: string, body: string, data: Record<string, string>) {
        this.title = title;
        this.body = body;
        this.data = data;
    }
}