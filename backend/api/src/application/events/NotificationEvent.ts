export interface INotificationEvent {
    title: string;
    body: string
    data?: Record<string,  string>
}

export class NotificationEvent implements INotificationEvent {
    public title: string;
    public body: string;
    public data?: Record<string, string>;

    constructor(title: string, body: string, data?: Record<string, string>) {
        this.title = title;
        this.body = body;
        this.data = data;
    }

    public static fromJson(json: INotificationEvent) {
        return new NotificationEvent(
             json['title'] ?? '',
            json['body'] ?? '',
            json['data'] ?? undefined
        )
    }
}